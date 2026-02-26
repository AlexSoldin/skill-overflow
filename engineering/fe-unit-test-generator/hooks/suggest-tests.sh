#!/bin/bash
# Outputs a systemMessage suggesting test generation when a new TypeScript/React
# source file is created without a corresponding colocated test file.
set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# Only handle .ts and .tsx files
if [[ ! "$file_path" =~ \.(ts|tsx)$ ]]; then
  exit 0
fi

basename=$(basename "$file_path")

# Skip exclusion patterns
if [[ "$basename" =~ \.test\.(ts|tsx)$ ]] || \
   [[ "$basename" =~ \.d\.ts$ ]] || \
   [[ "$basename" =~ \.config\.(ts|js|mts|cjs)$ ]] || \
   [[ "$basename" =~ \.stories\.(ts|tsx)$ ]] || \
   [[ "$basename" == "main.tsx" ]] || \
   [[ "$basename" == "main.ts" ]] || \
   [[ "$basename" == "App.tsx" ]] || \
   [[ "$basename" == "App.ts" ]] || \
   [[ "$basename" == "index.ts" ]] || \
   [[ "$basename" == "index.tsx" ]]; then
  exit 0
fi

# Skip src/test/ directory
if [[ "$file_path" == */src/test/* ]]; then
  exit 0
fi

# Resolve full path relative to project dir if path is relative
if [[ "$file_path" != /* ]]; then
  file_path="${CLAUDE_PROJECT_DIR}/${file_path}"
fi

# Derive expected test file path
dir=$(dirname "$file_path")
name_no_ext="${basename%.*}"
ext="${basename##*.}"
test_file="${dir}/${name_no_ext}.test.${ext}"

# If test file already exists, say nothing
if [ -f "$test_file" ]; then
  exit 0
fi

# Output suggestion via systemMessage
cat <<EOF
{
  "systemMessage": "📝 \`${basename}\` has no test file yet. Remind the user: run \`/fe-unit-test-generator:generate ${file_path}\` to generate unit tests for it."
}
EOF
