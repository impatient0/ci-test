#!/bin/bash

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

# 3. Ask Maven whats needs to be built
echo "Calculating impact tree..."

set +e
IMPACTED_ARTIFACTS=$(mvn -q \
  -Dexec.executable=echo \
  -Dexec.args='${project.artifactId}' \
  exec:exec \
  -pl "$AFFECTED_MODULES" \
  -amd \
  -am)
MVN_EXIT_CODE=$?
set -e

# Check if Maven failed
if [ $MVN_EXIT_CODE -ne 0 ]; then
  echo "::error::Maven failed to calculate dependencies!"
  mvn -Dexec.executable=echo -Dexec.args='${project.artifactId}' exec:exec -pl "$AFFECTED_MODULES" -amd -am
  exit 1
fi

DEPLOY_TARGETS=()

# 4. Process the list
while IFS= read -r artifact_id; do
  if [ -z "$artifact_id" ]; then continue; fi

  config_path="$artifact_id/deploy.env"

  # Check for deploy.env
  if [[ -f "$config_path" ]]; then
      echo "Found deployable service: $artifact_id"
      DEPLOY_TARGETS+=("\"$artifact_id\"")
  else
      echo "Skipping $artifact_id (No deploy.env found at $config_path)"
  fi
done <<< "$IMPACTED_ARTIFACTS"

# 5. Output JSON
JSON_ARRAY="[$(IFS=,; echo "${DEPLOY_TARGETS[*]}")]"
echo "Final Matrix: $JSON_ARRAY"
echo "matrix=$JSON_ARRAY" >> $GITHUB_OUTPUT