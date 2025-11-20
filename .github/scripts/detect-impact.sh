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

# Remove trailing comma
AFFECTED_MODULES=${AFFECTED_MODULES%,}

if [ -z "$AFFECTED_MODULES" ]; then
  echo "No modules affected."
  echo "matrix=[]" >> $GITHUB_OUTPUT
  exit 0
fi

# 3. Ask Maven whats needs to be built
IMPACTED_PATHS=$(mvn -q \
  -Dexec.executable=echo \
  -Dexec.args='${project.basedir}' \
  exec:exec \
  -pl "$AFFECTED_MODULES" \
  -amd \
  -am)

DEPLOY_TARGETS=()

while IFS= read -r module_path; do
  # 4. Check for deploy.env
  if [[ -f "$module_path/deploy.env" ]]; then
      module_name=$(basename "$module_path")
      echo "Found deployable service: $module_name"
      DEPLOY_TARGETS+=("\"$module_name\"")
  else
      echo "Skipping $module_path (No deploy.env found)"
  fi
done <<< "$IMPACTED_PATHS"

# 5. Output JSON for GitHub Actions Matrix
JSON_ARRAY="[$(IFS=,; echo "${DEPLOY_TARGETS[*]}")]"
echo "Final Matrix: $JSON_ARRAY"
echo "matrix=$JSON_ARRAY" >> $GITHUB_OUTPUT