#!/usr/bin/env bash
set -euo pipefail

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Missing file: $file" >&2
    exit 1
  fi
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  if ! grep -Eq "$pattern" "$file"; then
    echo "Missing ${description} in ${file}" >&2
    exit 1
  fi
}

require_file "codex-skills/course-design/SKILL.md"
require_file "codex-skills/learn-course/SKILL.md"
require_file "codex-skills/course-design/agents/openai.yaml"
require_file "codex-skills/learn-course/agents/openai.yaml"

require_pattern "codex-skills/course-design/SKILL.md" '^name: course-design$' "course-design skill name"
require_pattern "codex-skills/course-design/SKILL.md" '~/.codex/courses/<course-id>/course\.md' "Codex course path"
require_pattern "codex-skills/course-design/SKILL.md" '~/.codex/courses/profile\.md' "Codex global profile path"
require_pattern "codex-skills/course-design/SKILL.md" 'project profile.*overlay|overlay.*project profile' "profile overlay rule"
require_pattern "codex-skills/course-design/SKILL.md" 'course-design\.md' "Claude command source reference"

require_pattern "codex-skills/learn-course/SKILL.md" '^name: learn-course$' "learn-course skill name"
require_pattern "codex-skills/learn-course/SKILL.md" '~/.codex/courses/<course-id>/journal\.md' "Codex journal path"
require_pattern "codex-skills/learn-course/SKILL.md" 'profile global' "profile global command"
require_pattern "codex-skills/learn-course/SKILL.md" 'forget <topic>' "forget command"
require_pattern "codex-skills/learn-course/SKILL.md" 'yes/no/edit' "confirmation flow"
require_pattern "codex-skills/learn-course/SKILL.md" 'learn\.md' "Claude command source reference"

require_pattern "codex-skills/course-design/agents/openai.yaml" 'display_name: "Course Design"' "course-design display name"
require_pattern "codex-skills/course-design/agents/openai.yaml" 'default_prompt: "Use \$course-design' "course-design default prompt"
require_pattern "codex-skills/learn-course/agents/openai.yaml" 'display_name: "Learn Course"' "learn-course display name"
require_pattern "codex-skills/learn-course/agents/openai.yaml" 'default_prompt: "Use \$learn-course' "learn-course default prompt"

require_pattern "README.md" 'Codex' "Codex documentation"
require_pattern "README.md" 'codex-skills/course-design' "Codex course-design install path"
require_pattern "README.md" '~/.codex/skills' "Codex skills destination"
