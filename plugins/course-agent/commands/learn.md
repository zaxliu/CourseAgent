---
description: Resume tutorial progress and deliver a guided lesson for the next day
---

# Learn Command

Find `course.md` in the current repo, read progress state, then read all reference docs for the next day and deliver a guided lesson.

## Path Resolution

1. **Course ID**: Take the **absolute path** of CWD, strip the leading `/`, and replace all `/` with `--`. This is the **course ID**. Examples:
   - CWD = `/Users/lewis/Documents/code/better_kernels` → `Users--lewis--Documents--code--better_kernels`
   - CWD = `/Users/lewis/Documents/code/better_kernels/experiments/benchmarks/KernelBench` → `Users--lewis--Documents--code--better_kernels--experiments--benchmarks--KernelBench`
2. **Project root**: CWD is always the project root for reference path resolution.
3. **Find `course.md`**: Search `~/.claude/courses/<course-id>/course.md`. If not found, also check if there are sub-courses matching `<course-id>--*` and list them. If not found anywhere, fall back to CWD and immediate subdirectories. If still not found, tell the user and stop.
4. **Language**: Read `<!-- lang: xx -->` from `course.md` metadata. Use this language for all lesson delivery. If not present, fall back to matching the user's language.
5. **Project root override**: Read `<!-- project_root: ... -->` from `course.md` metadata. If present, use it. Otherwise use the computed project root from step 1.
6. **Sub-path**: Read `<!-- sub_path: ... -->` from `course.md` metadata. If present, resolve reference paths relative to `<project_root>/<sub_path>/`. Otherwise resolve relative to project root.
7. **Progress file**: `~/.claude/courses/<course-id>/progress.json`
8. **Journal file**: `~/.claude/courses/<course-id>/journal.md`
9. **Profile files**:
   - Global profile: `~/.claude/courses/profile.md`
   - Project profile: `~/.claude/courses/<course-id>/profile.md`

## User Profile

At startup, after resolving the course ID and before delivering a lesson:

1. Read the global profile if it exists: `~/.claude/courses/profile.md`
2. Read the project profile if it exists: `~/.claude/courses/<course-id>/profile.md`
3. Merge them for the current session. The project profile is an overlay on the global profile and should override conflicting global preferences for this course only.
4. Adapt the lesson style using the effective profile: language fallback, explanation depth, pace, examples, assumed background knowledge, topics to emphasize, and exercise style.

Profile files are plain Markdown so the user can inspect and edit them directly. Expected structure:

```markdown
# CourseAgent User Profile

## Knowledge Background
- Programming languages:
- Frameworks/tools:
- Domain knowledge:
- Current weak spots:

## Learning Preferences
- Preferred language:
- Explanation depth:
- Preferred examples:
- Pace:
- Exercise style:

## Course Design Preferences
- Default audience level:
- Default course length:
- Preferred scope:
- Topics to emphasize:
- Topics to avoid or keep brief:

## Interaction Preferences
- Likes:
- Dislikes:
- Feedback signals:

## Last Updated
YYYY-MM-DD
```

If no profile exists, behave exactly as before.

### Profile Display Commands

During a lesson or at startup:

- **`profile`**: Show the effective merged profile, noting that project profile values override global values.
- **`profile global`**: Show only `~/.claude/courses/profile.md`. If it does not exist, say so.
- **`profile project`**: Show only `~/.claude/courses/<course-id>/profile.md`. If it does not exist, say so.

After showing profile content, continue the lesson normally.

### Profile Update Flow

When the user gives meaningful feedback that implies a durable learning preference or background fact, propose a profile update before writing anything. Examples:

- "讲慢一点"
- "以后多给代码例子"
- "我已经熟悉 React，不用基础介绍"
- "这个课程偏理论了，下次多给练习"

Only store stable preferences or background facts likely to help future courses. Never store raw conversation transcripts. Do not store sensitive personal information unless the user explicitly asks.

Prefer updating the global profile for stable cross-project facts. Prefer updating the project profile for repo-specific goals or temporary context. If unsure whether a fact is global or project-specific, propose a project profile update by default.

Use this confirmation format:

```text
I can update your learning profile:

Global profile:
- Explanation depth: concise fundamentals, then code examples
- Existing React basics should be treated as known

Apply this update? yes/no/edit
```

- If the user says `yes`, write the proposed change to the relevant profile file and update `## Last Updated` to today's date in `YYYY-MM-DD`.
- If the user says `no`, do not write anything and continue normally.
- If the user says `edit`, ask for the revised wording, then write only the revised wording after the user provides it.

### Forget Flow

When the user says **`forget <topic>`**:

1. Search the global and project profiles for matching facts or preferences.
2. Propose the removal before writing anything.
3. Ask for confirmation with `yes/no/edit`.
4. Only remove or revise profile content after confirmation.
5. Update `## Last Updated` whenever a profile file changes.

Do not delete journal entries from `journal.md` during forget flow unless the user explicitly asks for journal edits.

## Journal System

The learning journal is a Markdown file that records each day's notes, Q&A, takeaways, and session summary. It is stored alongside the progress file and is human-readable.

### Journal Format

```markdown
# Learning Journal — <course-id>

## Day N · <topic>
**Date:** YYYY-MM-DD

### Notes
- <user note>
- <user note>

### Key Q&A
- **Q:** <question>
  **A:** <answer>

### Takeaways
- <user-written takeaway>

### Session Summary
- <auto-generated summary bullet>

---
```

### Journal Rules

- Create the journal file on first write (first `note:` or first `done`). Initialize with `# Learning Journal — <course-id>` header.
- Each day gets one `## Day N · <topic>` section. If the section already exists (e.g., user resumes a day), append to it rather than creating a duplicate.
- Key Q&A: max 3 entries per day. Pick the most substantive exchanges, skip trivial ones.
- Session Summary: max 3 bullets per day.
- **Do NOT save lesson content, Q&A, notes, or takeaways to Claude's auto memory system.** All learning-related persistence goes exclusively into the journal file. The auto memory system is for user preferences and project context — not for course content.
- **Journal behavior remains unchanged by profiles.** Lesson notes, Q&A, takeaways, and summaries still go only to `journal.md`; durable preferences and background facts go only to confirmed profile updates.

## Detecting Course Structure

Parse `course.md` for all `## Day N` section headings. Extract:
- The total number of days (the highest `N` found)
- Each day's topic, reference table, and `**Goal:**` line

Do NOT hardcode the day range — derive it dynamically from the file.

## Workflow

1. Find `course.md` using the path resolution rules above.
2. Parse the course structure to determine the valid day range (`0` to `max_day`).
3. Check whether the progress file exists (at `~/.claude/courses/<course-id>/progress.json`).
4. If the progress file exists, read it and validate that `current_day` is within the valid range. Use it as the learner's current progress.
5. If the progress file does not exist or is invalid, ask the user: `What's the highest day you've completed so far? (0-<max_day>)` and create the progress file with:
   - `current_day`: the highest completed day
   - `completed_days`: the inclusive list from `0` through `current_day`
   - `last_session_at`: today's date in `YYYY-MM-DD`
   - `notes`: an empty string
6. If `current_day` equals `max_day`, return the completion case output only.
7. If `current_day` is less than `max_day`, determine the next day to study. Then:
   a. **Quick Recap**: Check if the journal file exists and has an entry for the previous day (`current_day`). If so, display a brief recap (takeaways or session summary, max 3 lines) before the new lesson.
   b. Read ALL reference docs listed in that day's table from the course file (use the Read tool on each file, resolving relative paths against the project root + sub_path as described in Path Resolution).
   c. Synthesize the content into a guided lesson (see Output Format below), **in the language specified by `<!-- lang: ... -->` metadata**.
8. After outputting the lesson, do NOT update progress automatically. The user can now:
   - Continue asking questions about the lesson
   - Use `note: <text>` to save notes
   - Use `review` to browse past journal entries
   - Use `profile`, `profile global`, or `profile project` to inspect profile context
   - Use `forget <topic>` to remove confirmed profile facts
   - Say `done` when ready to advance
9. **Advance flow** — triggered when the user signals completion via ANY of these (case-insensitive): "done", "完成", "next", "下一课", "下一天", "finish", "finished". ALL of these keywords trigger the SAME full flow below — no shortcut, no skipping the journal:
   a. Ask: "Any key takeaways from today? (type them or say 'skip')"
   b. If the user provides takeaways, record them under `### Takeaways` in the journal.
   c. Auto-generate `### Key Q&A`: review the conversation and identify 1-3 substantive question-answer exchanges. If no questions were asked, omit this section.
   d. Auto-generate `### Session Summary`: write 2-3 bullets summarizing what was covered and any key clarifications.
   e. Write all sections to the journal file under the current day's heading.
   f. Update the progress file: increment `current_day`, append to `completed_days`, update `last_session_at`.

## Note Capture

When the user's message starts with `note:` (case-insensitive) during an active lesson:

1. Extract the text after the `note:` prefix.
2. Open (or create) the journal file. If no section exists for the current day, create one with the day header and today's date.
3. Append the note as a bullet under `### Notes`.
4. Respond briefly: "Noted." — then continue the conversation naturally. Do not repeat the note back or interrupt the lesson flow.

The user can send `note:` at any point during the lesson.

## Review Mode

When the user says `review` (case-insensitive) during a lesson:

- **`review`** (no arguments): Read the journal file and show a compact overview — for each day, display the day header and takeaway bullets only. If no journal exists, say "No journal entries yet."
- **`review day N`**: Read and display the full journal section for Day N. If that day has no entry, say so.

After showing the review, continue the lesson normally.

## List Mode

When the user says `list` (case-insensitive) during a lesson or at startup:

- Scan `~/.claude/courses/` for all directories whose name starts with `<course-id>` (i.e., exact match or `<course-id>--*` for sub-courses).
- For each, read `progress.json` (if exists) and `course.md` to determine total days and current progress.
- Display a table:

```
Courses for current project:

| Course ID | Progress | Status |
|---|---|---|
| Users--lewis--...--better_kernels (root) | Day 14/20 | In progress |
| Users--lewis--...--better_kernels--experiments--frameworks--autokernel | Day 7/7 | Complete ✓ |
| Users--lewis--...--better_kernels--experiments--benchmarks--KernelBench | Day 15/15 | Complete ✓ |
```

## Requirements

- **This is a guided lesson, not a link dump.** You must read the referenced files and teach the content.
- Extract only content from the next day's own references — do not mix in other days.
- Use the language specified in `<!-- lang: ... -->` metadata from `course.md`. If not present, match the user's language (if they've been writing in Chinese, teach in Chinese).
- Keep each section concise but substantive — the learner should understand the concept after reading your output without needing to open the source files.
- Include real examples from the repo (file paths, code snippets, config excerpts) to make concepts concrete.
- End with a hands-on exercise derived from the day's `**Goal:**` line.
- Use the effective merged profile to adapt teaching style, but do not let it override direct user requests in the current conversation.
- Do not infer or write profile changes without the confirmation flow.
- **Do NOT auto-advance progress.** Only trigger the advance flow when the user explicitly signals completion (e.g., "done", "完成", "next", "下一课", "下一天", "finish"). ALL of these must go through the full advance flow (takeaway prompt → auto Q&A → auto summary → journal write → progress update). Never skip the journal step.
- If the saved day is outside the valid range, re-ask and overwrite the invalid state.

## Output Format

### Normal case

```
### Quick Recap — Day X
<takeaway or summary bullets from previous day, max 3 lines. Omit this section if no journal entry exists.>

---

## Day Y · <topic>

### Overview
Brief intro: what this concept is and why it matters (2-3 sentences).

### Key Concepts
Teach the core ideas from the reference docs, organized logically.
Use subheadings, bullet points, tables, or code blocks as appropriate.
Include concrete examples from this repo.

### Hands-on Exercise
One practical task derived from the day's **Goal:** line.
Give specific steps the learner can follow in this repo.

### Quick Reference
A compact cheat-sheet (table or bullet list) summarizing the most important fields/patterns from this day.

---
Progress: Day Y · "done"/"完成"/"next" to advance | "note: ..." to save a note | "review" to browse journal | "list" to see all courses
```

### Completion case

```
## Course Complete!

Congratulations — you've finished all days.

### Review
Guidance for reviewing key concepts and applying them to your own projects.

You can say "review" to browse your learning journal from the entire course.
```
