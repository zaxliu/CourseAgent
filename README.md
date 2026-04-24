# CourseAgent

> AI-powered interactive course designer and guided learning agent for Claude Code.

CourseAgent turns any codebase into a structured multi-day course. It scans your repo, designs a syllabus, delivers guided daily lessons, and keeps a learning journal — all inside your terminal.

## Features

- **`/CourseAgent:course-design`** — Generate or refine a `course.md` syllabus from any repo
  - Auto-detects independent sub-modules and suggests nested sub-courses
  - Multi-language support (ask at creation time)
  - References real files in the repo + curated external links
  - Progress bar visualization in Course Overview

- **`/CourseAgent:learn`** — Resume and deliver the next guided lesson
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
  ├─ /CourseAgent:course-design    → scans repo → generates course.md
  │                                   stored in ~/.claude/courses/<path-id>/
  │
  └─ /CourseAgent:learn            → reads course.md → delivers lesson
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
# Clone the repo
git clone git@github.com:zaxliu/CourseAgent.git

# Symlink into Claude Code plugins
ln -s /path/to/CourseAgent ~/.claude/plugins/CourseAgent
```

Then add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "CourseAgent@local": true
  }
}
```

And to `~/.claude/plugins/installed_plugins.json` (inside the `"plugins"` object):

```json
"CourseAgent@local": [
  {
    "scope": "project",
    "installPath": "/path/to/CourseAgent",
    "version": "0.1.0",
    "installedAt": "2026-04-24T00:00:00.000Z",
    "lastUpdated": "2026-04-24T00:00:00.000Z",
    "projectPath": "/Users/you"
  }
]
```

## Usage

```bash
# In any project directory:
cd ~/projects/myapp

# Design a course for this repo
# (asks language, audience, detects sub-modules)
/CourseAgent:course-design

# Start learning
/CourseAgent:learn

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
