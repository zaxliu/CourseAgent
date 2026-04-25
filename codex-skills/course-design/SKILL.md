---
name: course-design
description: Use when the user wants Codex to create, review, or refine a repo-specific course.md syllabus for learning a codebase, including sub-course detection and profile-aware defaults.
---

# Course Design

Create or refine a structured multi-day learning syllabus for the current repository.

This is the Codex adaptation of the Claude Code command at `plugins/course-agent/commands/course-design.md`. Keep behavior aligned with that source when updating this skill.

## Storage

Use Codex-local storage by default:

- Course root: `~/.codex/courses/`
- Course file: `~/.codex/courses/<course-id>/course.md`
- Global profile: `~/.codex/courses/profile.md`
- Project profile: `~/.codex/courses/<course-id>/profile.md`

The course ID is the absolute path of the current working directory with the leading `/` stripped and all `/` characters replaced by `--`.

## Profile

Before asking course creation questions or editing a course:

1. Resolve `<course-id>`.
2. Read `~/.codex/courses/profile.md` if it exists.
3. Read `~/.codex/courses/<course-id>/profile.md` if it exists.
4. Merge them for decision-making. The project profile is an overlay on the global profile and overrides conflicting global preferences for this course only.
5. Use the effective profile to recommend language, audience, length, scope, topic emphasis, topic ordering, and exercise style.

Profile guidance is advisory. Explicit user arguments and direct answers always win.

When profile data affects defaults, show:

```text
Based on your profile, I recommend:
- Language: zh-CN
- Audience: intermediate
- Style: repo-first explanations with hands-on exercises
```

## Workflow

1. Resolve `<course-id>` and look for `~/.codex/courses/<course-id>/course.md`.
2. If no course exists, enter create mode. If it exists, enter edit mode.
3. In create mode, read the repo README, local instructions, and directory structure.
4. Use web research only when available and useful; prioritize official docs for external references.
5. Ask at most one round of focused questions for language, audience, scope, and length. Skip questions already answered by the user.
6. Detect independent subdirectories using markers such as `README.md`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `setup.py`, or `Makefile`.
7. Write `course.md` to `~/.codex/courses/<course-id>/course.md`.

## Course Format

```markdown
<!-- lang: zh-CN -->
<!-- project_root: /absolute/path/to/project -->
<!-- sub_path: backend/auth -->

# <Course Title>

> One-line description of the course.

## Day 0 · <Title>

**Topic:** One-line description

| What to Learn | Reference |
|---|---|
| Concept description | [`path/to/file`](path/to/file) |

**Goal:** One actionable sentence

## Course Overview
```

Rules:

- References must be real repo files or explicit external URLs.
- All file references are relative to the project root, or to the sub-path root for sub-courses.
- If no suitable file exists, use a prose description instead of a fake link.
- Order days by dependency: foundation, core, advanced, capstone.
- Day 0 is setup or orientation.
- Each day should have one focused topic and an actionable goal.
- Write all course content in the selected language.

## Edit Mode

When refining an existing course:

1. Read the current `course.md` and preserve its language metadata.
2. Ask one clarifying question only if the request is ambiguous.
3. Inspect affected day sections and dependent course-level sections before editing.
4. Keep edits minimal and preserve unaffected day sections when possible.
5. Keep day numbering and course overview consistent.
6. Summarize changed days and sequencing impact.

Do not read or modify progress or journal files from this skill.
