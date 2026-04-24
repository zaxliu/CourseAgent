# CourseAgent Marketplace Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert this repository from a root-level local Claude plugin into a GitHub-hosted Claude marketplace repository that exposes one installable plugin at `plugins/course-agent/`.

**Architecture:** The repository root will own `.claude-plugin/marketplace.json`, while the actual plugin moves under `plugins/course-agent/` with its own `.claude-plugin/plugin.json` and `commands/` directory. CI and README will be updated to validate and document the new marketplace-first install flow.

**Tech Stack:** Git, JSON manifests, Markdown command files, GitHub Actions

---

### Task 1: Create Marketplace Root Manifest

**Files:**
- Create: `.claude-plugin/marketplace.json`
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Write the marketplace manifest content**

```json
{
  "name": "courseagent",
  "version": "0.1.0",
  "description": "Claude Code marketplace for the CourseAgent learning plugin",
  "plugins": [
    {
      "name": "course-agent",
      "description": "AI-powered interactive course designer and guided learning agent for Claude Code",
      "source": "./plugins/course-agent",
      "category": "learning"
    }
  ]
}
```

- [ ] **Step 2: Move the existing root plugin manifest into the plugin subdirectory target**

Run: `mkdir -p plugins/course-agent/.claude-plugin`

Expected: directory exists at `plugins/course-agent/.claude-plugin`

- [ ] **Step 3: Remove the root plugin manifest once the plugin copy exists**

Run: `git rm .claude-plugin/plugin.json`

Expected: root manifest is staged for deletion so `.claude-plugin/` only contains `marketplace.json`

- [ ] **Step 4: Commit the marketplace manifest groundwork**

```bash
git add .claude-plugin/marketplace.json .claude-plugin/plugin.json
git commit -m "Add marketplace root manifest"
```

### Task 2: Relocate Plugin Files Under `plugins/course-agent`

**Files:**
- Create: `plugins/course-agent/.claude-plugin/plugin.json`
- Create: `plugins/course-agent/commands/course-design.md`
- Create: `plugins/course-agent/commands/learn.md`
- Modify: `.gitignore`

- [ ] **Step 1: Write the relocated plugin manifest**

```json
{
  "name": "course-agent",
  "version": "0.1.0",
  "description": "AI-powered interactive course designer and guided learning agent with auto-memory",
  "author": {
    "name": "lewis"
  },
  "commands": [
    "./commands/course-design.md",
    "./commands/learn.md"
  ],
  "keywords": ["learning", "courses", "agent", "interactive", "memory"]
}
```

- [ ] **Step 2: Move the command files into the plugin directory**

Run:

```bash
mkdir -p plugins/course-agent/commands
mv commands/course-design.md plugins/course-agent/commands/course-design.md
mv commands/learn.md plugins/course-agent/commands/learn.md
```

Expected: root `commands/` directory becomes empty and plugin commands exist under `plugins/course-agent/commands/`

- [ ] **Step 3: Keep `.gitignore` compatible with the new layout**

```gitignore
.DS_Store
```

- [ ] **Step 4: Commit the plugin relocation**

```bash
git add plugins/course-agent/.claude-plugin/plugin.json plugins/course-agent/commands/course-design.md plugins/course-agent/commands/learn.md .gitignore
git commit -m "Move CourseAgent into marketplace plugin layout"
```

### Task 3: Update CI And Repository Documentation

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `README.md`

- [ ] **Step 1: Update CI to validate the relocated plugin manifest**

Key changes to apply in `.github/workflows/ci.yml`:

```yaml
      - name: Validate plugin.json
        run: |
          echo "=== Checking plugin.json ==="
          cat plugins/course-agent/.claude-plugin/plugin.json | python3 -c "
          import json, sys
          data = json.load(sys.stdin)
          assert 'name' in data, 'Missing name'
          assert 'version' in data, 'Missing version'
          assert 'commands' in data, 'Missing commands'
          print(f'Plugin: {data[\"name\"]} v{data[\"version\"]}')
          print(f'Commands: {len(data[\"commands\"])}')
          "

      - name: Validate command files exist
        run: |
          echo "=== Checking command files ==="
          for cmd in $(python3 -c "
          import json
          data = json.load(open('plugins/course-agent/.claude-plugin/plugin.json'))
          for c in data['commands']:
            print(f\"plugins/course-agent/{c[2:]}\")
          "); do
            if [ ! -f "$cmd" ]; then
              echo "FAIL: $cmd not found"
              exit 1
            fi
            echo "OK: $cmd"
          done

      - name: Validate command frontmatter
        run: |
          echo "=== Checking YAML frontmatter ==="
          for f in plugins/course-agent/commands/*.md; do
            if ! head -1 "$f" | grep -q '^---$'; then
              echo "FAIL: $f missing YAML frontmatter"
              exit 1
            fi
            if ! grep -q '^description:' "$f"; then
              echo "FAIL: $f missing description in frontmatter"
              exit 1
            fi
            echo "OK: $f"
          done
```

- [ ] **Step 2: Update markdown lint targets**

```yaml
      - name: Lint markdown
        uses: DavidAnson/markdownlint-cli2-action@v19
        with:
          globs: |
            plugins/course-agent/commands/*.md
            README.md
        continue-on-error: true
```

- [ ] **Step 3: Rewrite README install section for GitHub marketplace install**

The README install section must contain these exact command examples:

```bash
/plugin marketplace add zaxliu/CourseAgent
/plugin install course-agent@courseagent
```

The README description should also explain that:

- this repository is a Claude Code marketplace repository
- `course-agent` is the installable plugin name
- local symlink installation is no longer the primary path

- [ ] **Step 4: Commit CI and README updates**

```bash
git add .github/workflows/ci.yml README.md
git commit -m "Update CI and docs for marketplace install"
```

### Task 4: Verify The Marketplace Migration End To End

**Files:**
- Test: `.claude-plugin/marketplace.json`
- Test: `plugins/course-agent/.claude-plugin/plugin.json`
- Test: `plugins/course-agent/commands/course-design.md`
- Test: `plugins/course-agent/commands/learn.md`

- [ ] **Step 1: Validate the marketplace and plugin manifests**

Run:

```bash
python3 - <<'PY'
import json
from pathlib import Path

market = json.loads(Path('.claude-plugin/marketplace.json').read_text())
assert market['name'] == 'courseagent'
assert market['plugins'][0]['name'] == 'course-agent'
assert market['plugins'][0]['source'] == './plugins/course-agent'

plugin = json.loads(Path('plugins/course-agent/.claude-plugin/plugin.json').read_text())
assert plugin['name'] == 'course-agent'
assert plugin['commands'] == ['./commands/course-design.md', './commands/learn.md']
print('marketplace and plugin manifests OK')
PY
```

Expected: `marketplace and plugin manifests OK`

- [ ] **Step 2: Validate referenced command files and frontmatter**

Run:

```bash
python3 - <<'PY'
import json
from pathlib import Path

plugin = json.loads(Path('plugins/course-agent/.claude-plugin/plugin.json').read_text())
for rel in plugin['commands']:
    path = Path('plugins/course-agent') / rel[2:]
    assert path.is_file(), f'missing command file: {path}'
    lines = path.read_text().splitlines()
    assert lines and lines[0] == '---', f'missing frontmatter: {path}'
    assert any(line.startswith('description:') for line in lines[:10]), f'missing description: {path}'
    print(f'OK: {path}')
PY
```

Expected: two `OK:` lines, one for each command file

- [ ] **Step 3: Run the same CI-style checks locally**

Run:

```bash
python3 - <<'PY'
import json
from pathlib import Path
data = json.loads(Path('plugins/course-agent/.claude-plugin/plugin.json').read_text())
assert 'name' in data and 'version' in data and 'commands' in data
print(f"Plugin: {data['name']} v{data['version']}")
print(f"Commands: {len(data['commands'])}")
PY
python3 - <<'PY'
import json
from pathlib import Path
data = json.loads(Path('plugins/course-agent/.claude-plugin/plugin.json').read_text())
for cmd in data['commands']:
    p = Path('plugins/course-agent') / cmd[2:]
    assert p.is_file(), f'{p} not found'
    print(f'OK: {p}')
PY
python3 - <<'PY'
from pathlib import Path
for f in sorted(Path('plugins/course-agent/commands').glob('*.md')):
    text = f.read_text()
    lines = text.splitlines()
    assert lines and lines[0] == '---', f'{f} missing YAML frontmatter'
    assert any(line.startswith('description:') for line in lines[:10]), f'{f} missing description in frontmatter'
    print(f'OK: {f}')
PY
```

Expected:

- `Plugin: course-agent v0.1.0`
- `Commands: 2`
- `OK:` lines for both command files

- [ ] **Step 4: Commit the verified migration state**

```bash
git add .claude-plugin/marketplace.json plugins/course-agent/.claude-plugin/plugin.json plugins/course-agent/commands .github/workflows/ci.yml README.md
git commit -m "Verify marketplace migration layout"
```

- [ ] **Step 5: Push the branch**

Run: `git push origin main`

Expected: remote `main` advances with the marketplace migration commits
