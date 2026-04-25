#!/usr/bin/env bash
set -euo pipefail

course_design="plugins/course-agent/commands/course-design.md"
learn="plugins/course-agent/commands/learn.md"
readme="README.md"

require_pattern() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  if ! grep -Eq "$pattern" "$file"; then
    echo "Missing ${description} in ${file}" >&2
    exit 1
  fi
}

require_pattern "$course_design" '~/.claude/courses/profile\.md' 'global profile path'
require_pattern "$course_design" '~/.claude/courses/<course-id>/profile\.md' 'project profile path'
require_pattern "$course_design" 'project profile.*overlay|overlay.*project profile' 'project profile overlay rule'
require_pattern "$course_design" 'explicit.*(arguments|answers).*win|arguments.*override.*profile' 'explicit user input precedence'
require_pattern "$course_design" 'Based on your profile, I recommend' 'profile-derived recommendation prompt'

require_pattern "$learn" '~/.claude/courses/profile\.md' 'global profile path'
require_pattern "$learn" '~/.claude/courses/<course-id>/profile\.md' 'project profile path'
require_pattern "$learn" 'profile global' 'global profile command'
require_pattern "$learn" 'profile project' 'project profile command'
require_pattern "$learn" 'forget <topic>' 'forget command'
require_pattern "$learn" 'yes/no/edit' 'profile update confirmation flow'
require_pattern "$learn" 'Never store raw conversation transcripts' 'profile storage rule'
require_pattern "$learn" 'Journal behavior remains unchanged|journal.*unchanged|journal.*only' 'journal separation rule'

require_pattern "$readme" '~/.claude/courses/profile\.md' 'documented global profile path'
require_pattern "$readme" 'profile global' 'documented profile commands'
