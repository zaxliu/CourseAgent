---
description: Generate, review, or refine a tutorial syllabus in `course.md`
---

# Course Design Command

Generate a new `course.md` or evolve an existing one as a structured multi-day course.

## Path Resolution

1. **Course ID**: Take the **absolute path** of CWD, strip the leading `/`, and replace all `/` with `--`. This is the **course ID**. Examples:
   - CWD = `/Users/lewis/Documents/code/better_kernels` → course ID = `Users--lewis--Documents--code--better_kernels`
   - CWD = `/Users/lewis/Documents/code/better_kernels/experiments/benchmarks/KernelBench` → course ID = `Users--lewis--Documents--code--better_kernels--experiments--benchmarks--KernelBench`
   - This is deterministic — no git logic, no renaming when nesting changes.
2. **Project root**: CWD is always the project root for reference path resolution.
3. **Find `course.md`**: Search `~/.claude/courses/<course-id>/course.md`. If not found, fall back to CWD and its immediate subdirectories for backwards compatibility.
4. If found, enter **Edit mode**. If not found, enter **Create mode**.

---

## User Profile

Before asking course creation questions or editing an existing course:

1. Resolve the course ID using the Path Resolution rule above.
2. Read the global profile if it exists: `~/.claude/courses/profile.md`
3. Read the project profile if it exists: `~/.claude/courses/<course-id>/profile.md`
4. Combine them for decision-making. The project profile is an overlay on the global profile and should override conflicting global preferences for this course only.
5. Use the effective profile to choose or recommend defaults for language, audience, length, scope, topic emphasis, topic ordering, and exercise style.

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

Profile guidance is advisory. Do not silently override direct user arguments: `$ARGUMENTS` and explicit answers always win over profile-derived defaults.

If profile data influences the normal question round, show the recommendation first:

```text
Based on your profile, I recommend:
- Language: zh-CN
- Audience: intermediate
- Style: repo-first explanations with hands-on exercises
```

If no profile exists, behave exactly as before.

## Create Mode (no `course.md` found)

### Step 0 — Language selection

Ask the user to choose the course language using AskUserQuestion:
- **中文 (zh-CN)** (Recommended)
- **English (en)**
- Other (user specifies)

If the effective profile includes a preferred language, use it as the recommended option. If the user provides the language in `$ARGUMENTS`, skip this question.

### Step 1 — Understand the repo and domain

- Read `README.md`, `CLAUDE.md`, and scan the directory structure to understand what this repo is about.
- Identify the key concepts, tools, patterns, and files a learner would need to master.
- **Web research**: Use WebSearch to find official docs, tutorials, and learning roadmaps for the repo's core technologies. This helps determine:
  - What concepts are essential vs nice-to-have
  - The recommended learning order in the community
  - Common beginner pitfalls to address early

### Step 1.5 — Sub-course detection

Scan top-level and second-level subdirectories for **independence markers**: `README.md`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `setup.py`, `Makefile` (with its own build targets).

If any are found:
1. Present the list to the user: "These subdirectories look independent — create sub-courses for any of them?" (use AskUserQuestion with multiSelect)
2. For each confirmed sub-directory:
   - Its course ID is the sub-directory's **absolute path**, strip leading `/`, replace `/` with `--` (same rule as all course IDs)
   - Generate a separate `course.md` at `~/.claude/courses/<sub-course-id>/course.md`
   - Follow the same Step 2–4 flow for each sub-course, scoped to that subdirectory
3. In the **root** `course.md`, add a `## Sub-courses` section listing all sub-courses:
   ```markdown
   ## Sub-courses

   | Module | Course ID | Days |
   |---|---|---|
   | Backend Auth | `Users--lewis--projects--myapp--backend--auth` | 5 |
   | Frontend UI | `Users--lewis--projects--myapp--frontend` | 3 |
   ```

If no independent subdirectories are found, or if CWD is already a subdirectory (not repo root), skip this step.

### Step 2 — Ask the user (one round max)

Ask up to 3 focused questions to determine:
- **Audience**: Who is this course for? (beginner / intermediate / advanced)
- **Scope**: Full repo coverage or a specific subset?
- **Length**: How many days? (suggest a default based on the repo's complexity)

Use the effective profile to prefill recommendations for these questions. For example, if the profile says the learner prefers concise, hands-on backend architecture courses, recommend that scope and style while still allowing the user to choose differently.

If the user gives enough context upfront (e.g., via `$ARGUMENTS`), skip the questions and proceed.

### Step 3 — Generate `course.md`

Write `course.md` to `~/.claude/courses/<course-id>/course.md` (create the directory if needed) using this structure:

```markdown
<!-- lang: zh-CN -->
<!-- project_root: /absolute/path/to/project -->
<!-- sub_path: backend/auth -->

# <Course Title>

> One-line description of the course.

---

## Day 0 · <Title>

**Topic:** One-line description

| What to Learn | Reference |
|---|---|
| Concept description | [`path/to/file`](path/to/file) |
| ... | ... |

**Goal:** One actionable sentence

---

## Day 1 · <Title>
...

---

## Sub-courses

(only in root course if sub-courses exist)

| Module | Course ID | Days |
|---|---|---|
| ... | ... | ... |

---

## Course Overview

​```
Day 0  <Title>       ████░░░░░░░░░░░░░░░░  <Phase>
Day 1  <Title>       █████░░░░░░░░░░░░░░░  <Phase>
...
​```
```

### Metadata comments

- `<!-- lang: xx -->` — the chosen language code. **All course content (day titles, topics, goals) must be written in this language.**
- `<!-- project_root: ... -->` — absolute path to project root, used by `/learn` to resolve references.
- `<!-- sub_path: ... -->` — (sub-courses only) relative path from project root to the sub-directory this course covers.

### Generation Rules

- **References must be real files** — use Glob/Read to verify each path exists before linking. All file references are relative to the project root (or sub-path root for sub-courses). If no suitable file exists, write the reference as a prose description instead of a fake link.
- **Supplement with external links** — for each day, use WebSearch to find 1-2 high-quality external references (official docs, authoritative tutorials, blog posts). Add them to the reference table with full URLs, marked as `[External]`. Example: `| OAuth 2.0 flow explained | [External] [OAuth 2.0 Simplified](https://example.com/oauth) |`
- **Order by dependency** — earlier days should not depend on later days. Foundation → Core → Advanced → Capstone.
- **Each day gets one focused topic** — don't overload a single day.
- **Goals are actionable** — each `**Goal:**` should describe something the learner can do or build, not just "understand X".
- **Course Overview** at the bottom shows a progress bar visualization.
- Day 0 is always setup/orientation.
- **Write all content in the language specified by `<!-- lang: ... -->`.**

### Step 4 — Summarize

After writing, output a brief summary: number of days, topic flow, and which phase each day belongs to. If sub-courses were created, list them too.

---

## Edit Mode (existing `course.md` found)

### Workflow

1. Read the existing `course.md`. Extract `<!-- lang: ... -->` from metadata — use that language for all edits and communication.
2. If the edit involves adding new topics or days, use WebSearch to research the topic — find official docs, best practices, and learning resources to inform the syllabus design.
3. Determine whether the user's request is specific enough to act on.
3. If the request is ambiguous, ask one focused clarifying question first. Do not turn this into an open-ended interview.
4. Analyze the current course structure before proposing edits, and inspect the affected day sections plus any dependent course-level sections before changing them.
5. Preserve the existing day-section format unless the user explicitly asks to change it.
6. Keep edits minimal in scope: preserve unaffected day sections verbatim when possible.
7. Propose a concrete syllabus update, or edit `course.md` directly when the request is explicit enough.
8. Keep day numbering and ordering consistent after edits.
9. When adding, splitting, or reordering days, explain the sequencing consequences for the rest of the course and update any dependent summaries in `course.md`, such as `## Course Overview` and `## Sub-courses`, when they are affected.
10. Summarize what changed or what is being proposed, which day or days are affected, and any sequencing impact on the rest of the course.

---

## Requirements (both modes)

- Treat this as a course-authoring workflow, not a learner assistant.
- Keep `/course-design` separate from `/learn`; do not read or modify any progress files.
- Read profile files only for stable preferences and background context. Do not write profile updates from `/course-design`.
- Preserve these conventions in `course.md` unless explicitly changed:
  - `## Day N · Title`
  - `**Topic:**`
  - `| What to Learn | Reference |`
  - `**Goal:**`
- Keep day numbering and ordering consistent after edits.
- If the request conflicts with the current course sequence, explain the tradeoff and recommend a better order.
- If references are missing for a proposed day, leave a clear prose placeholder direction instead of inventing fake links.
