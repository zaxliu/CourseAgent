# CourseAgent

> GitHub-hosted Claude Code marketplace for the CourseAgent learning plugin.

CourseAgent turns any codebase into a structured multi-day course. It scans your repo, designs a syllabus, delivers guided daily lessons, and keeps a learning journal, all inside Claude Code.

This repository is a Claude Code marketplace. The installable plugin name is `course-agent`, and the marketplace name is `courseagent`.

## Features

- **`/course-agent:course-design`** — Generate or refine a `course.md` syllabus from any repo
  - Auto-detects independent sub-modules and suggests nested sub-courses
  - Multi-language support (ask at creation time)
  - References real files in the repo + curated external links
  - Progress bar visualization in Course Overview

- **`/course-agent:learn`** — Resume and deliver the next guided lesson
  - Reads all reference docs and synthesizes a structured lesson
  - Interactive Q&A during the lesson
  - `note: ...` to capture notes mid-lesson
  - `done` / `next` to advance (with auto-generated journal entries)
  - `review` to browse past learning journal
  - `list` to see all courses and progress for current project

## How It Works

```
You (in any repo)
  │
  ├─ /course-agent:course-design   → scans repo → generates course.md
  │                                   stored in ~/.claude/courses/<path-id>/
  │
  └─ /course-agent:learn           → reads course.md → delivers lesson
                                     tracks progress in progress.json
                                     records journal in journal.md
```

### Course Storage

All course data lives under `~/.claude/courses/`, keyed by the **absolute path** of the project directory:

```
~/.claude/courses/
  Users--lewis--projects--myapp/
    course.md        # syllabus
    progress.json    # current day, completed days
    journal.md       # learning notes, Q&A, takeaways
  Users--lewis--projects--myapp--backend--auth/
    course.md        # sub-course for backend/auth
    ...
```

### Nested Sub-courses

When a project has deep directory structure with independent modules (detected by `README.md`, `package.json`, `pyproject.toml`, etc.), CourseAgent suggests creating sub-courses. Each sub-course has its own syllabus, progress, and journal.

## Install

```bash
# Add this GitHub repository as a Claude marketplace
/plugin marketplace add zaxliu/CourseAgent

# Install the plugin from that marketplace
/plugin install course-agent@courseagent
```

After installation, the commands are available under the `course-agent` namespace.

## Development Layout

```text
.claude-plugin/marketplace.json
plugins/course-agent/.claude-plugin/plugin.json
plugins/course-agent/commands/course-design.md
plugins/course-agent/commands/learn.md
```

## Usage

```bash
# In any project directory:
cd ~/projects/myapp

# Design a course for this repo
# (asks language, audience, detects sub-modules)
/course-agent:course-design

# Start learning
/course-agent:learn

# During a lesson:
note: this pattern is similar to the observer pattern
done                    # advance to next day
review                  # browse journal
review day 3            # see full journal for day 3
list                    # see all courses for this project
```

## Course Format

Courses follow a structured markdown format:

```markdown
<!-- lang: zh-CN -->
<!-- project_root: /Users/lewis/projects/myapp -->
<!-- sub_path: backend/auth -->

# Course Title

## Day 0 · Setup
**Topic:** ...
| What to Learn | Reference |
|---|---|
| ... | [`path/to/file`](path/to/file) |
| ... | [External] [Title](https://...) |
**Goal:** ...

## Course Overview
Day 0  Setup       ████░░░░░░  Foundation
Day 1  Core        ████████░░  Core
...
```

## License

[MIT](LICENSE)
