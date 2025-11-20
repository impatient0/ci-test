#!/bin/bash
set -e

# 1. Detect what files changed
CHANGED_FILES=$(git diff --name-only HEAD^ HEAD)

# 2. Find which modules these files belong to
AFFECTED_MODULES=""
for file in $CHANGED_FILES; do
  dir=$(dirname "$file")
  while [[ "$dir" != "." ]]; do
    if [[ -f "$dir/pom.xml" ]]; then
      AFFECTED_MODULES+="$dir,"
      break
    fi
    dir=$(dirname "$dir")
  done
done

AFFECTED_MODULES=${AFFECTED_MODULES%,}

if [ -z "$AFFECTED_MODULES" ]; then
  echo "No modules affected."
  echo "matrix=[]" >> $GITHUB_OUTPUT
  exit 0
fi

echo "Affected modules: $AFFECTED_MODULES"

# 3. Install changed dependencies to local cache
echo "Installing dependencies to local Maven cache..."
mvn install -q -DskipTests -Dmaven.javadoc.skip=true -pl "$AFFECTED_MODULES" -am

# 4. Calculate impact tree
echo "Calculating downstream impact..."

IMPACTED_ARTIFACTS=$(mvn -q \
  -Dexec.executable=echo \
  -Dexec.args='${project.artifactId}' \
  exec:exec \
  -pl "$AFFECTED_MODULES" \
  -amd)

# 5. Filter for deployable services
DEPLOY_TARGETS=()

while IFS= read -r artifact_id; do
  if [ -z "$artifact_id" ]; then continue; fi

  # Check for deploy.env
  config_path="$artifact_id/deploy.env"

  if [[ -f "$config_path" ]]; then
      echo "Found deployable service: $artifact_id"
      DEPLOY_TARGETS+=("\"$artifact_id\"")
  else
      echo "Skipping $artifact_id (No deploy.env found)"
  fi
done <<< "$IMPACTED_ARTIFACTS"

# 6. Output JSON
JSON_ARRAY="[$(IFS=,; echo "${DEPLOY_TARGETS[*]}")]"
echo "Final Matrix: $JSON_ARRAY"
echo "matrix=$JSON_ARRAY" >> $GITHUB_OUTPUT