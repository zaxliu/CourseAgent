---
name: learn-course
description: Use when the user wants Codex to teach or resume a CourseAgent lesson from course.md, manage progress and journal entries, or inspect/update the learning profile with confirmation.
---

# Learn Course

Resume CourseAgent progress and deliver the next guided lesson for the current repository.

This is the Codex adaptation of the Claude Code command at `plugins/course-agent/commands/learn.md`. Keep behavior aligned with that source when updating this skill.

## Storage

Use Codex-local storage by default:

- Course root: `~/.codex/courses/`
- Course file: `~/.codex/courses/<course-id>/course.md`
- Progress file: `~/.codex/courses/<course-id>/progress.json`
- Journal file: `~/.codex/courses/<course-id>/journal.md`
- Global profile: `~/.codex/courses/profile.md`
- Project profile: `~/.codex/courses/<course-id>/profile.md`

The course ID is the absolute path of the current working directory with the leading `/` stripped and all `/` characters replaced by `--`.

## Startup

1. Resolve `<course-id>` and find `~/.codex/courses/<course-id>/course.md`.
2. If not found, check for sub-courses whose IDs start with `<course-id>--`. If none exist, tell the user to run the course-design skill first.
3. Read course metadata: `<!-- lang: ... -->`, `<!-- project_root: ... -->`, and `<!-- sub_path: ... -->`.
4. Read `progress.json` if it exists. If missing or invalid, ask the user for the highest day completed and create it.
5. Read the global and project profiles if they exist. The project profile is an overlay on the global profile.
6. Parse all `## Day N` headings dynamically; do not hardcode the day range.

## Teaching

For the next uncompleted day:

1. Show a quick recap from the prior journal entry when available.
2. Read all referenced local files for that day.
3. Synthesize a guided lesson in the course language.
4. Include concrete examples from the repo.
5. End with one hands-on exercise derived from the day's `**Goal:**`.
6. Do not auto-advance progress.

Use the effective profile to adapt pace, explanation depth, examples, assumed background knowledge, and exercise style. Direct user requests in the current conversation override profile guidance.

## Lesson Commands

During a lesson:

- `note: <text>`: Append the note under the current day's `### Notes` in `~/.codex/courses/<course-id>/journal.md`.
- `review`: Show compact journal takeaways by day.
- `review day N`: Show the full journal section for Day N.
- `list`: Show matching root and sub-course progress for the current project.
- `profile`: Show the effective merged profile.
- `profile global`: Show `~/.codex/courses/profile.md`.
- `profile project`: Show `~/.codex/courses/<course-id>/profile.md`.
- `forget <topic>`: Propose removing matching profile facts.
- `done`, `完成`, `next`, `下一课`, `下一天`, `finish`, or `finished`: Start the advance flow.

## Advance Flow

When the user explicitly finishes a lesson:

1. Ask for key takeaways, allowing `skip`.
2. Write takeaways to the journal if provided.
3. Add up to 3 substantive Q&A entries from the session when available.
4. Add a 2-3 bullet session summary.
5. Increment `current_day`, append to `completed_days`, and update `last_session_at`.

Journal behavior remains unchanged by profiles. Lesson notes, Q&A, takeaways, and summaries go only to `journal.md`.

## Profile Updates

When feedback implies a durable preference or background fact, propose a profile update before writing. Examples:

- "讲慢一点"
- "以后多给代码例子"
- "我已经熟悉 React，不用基础介绍"
- "这个课程偏理论了，下次多给练习"

Never store raw conversation transcripts. Store only durable preferences or background facts likely to help future courses. Do not store sensitive personal information unless the user explicitly asks.

Prefer global profile updates for stable cross-project facts. Prefer project profile updates for repo-specific goals or temporary context. If unsure, propose the project profile by default.

Use this confirmation format:

```text
I can update your learning profile:

Project profile:
- Focus this repo's lessons on backend architecture.

Apply this update? yes/no/edit
```

Only write after `yes`. If the user says `edit`, ask for revised wording and write that. Update `## Last Updated` whenever a profile file changes.

For `forget <topic>`, search global and project profiles, propose matching removals, and use the same `yes/no/edit` confirmation flow before changing files.
