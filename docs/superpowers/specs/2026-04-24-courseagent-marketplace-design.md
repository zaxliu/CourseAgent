# CourseAgent Marketplace Design

## Summary

Convert the current `CourseAgent` repository from a single local-install plugin repository into a GitHub-hosted Claude Code marketplace repository that contains one installable plugin: `course-agent`.

The repository itself will become the marketplace root. The plugin implementation will move under `plugins/course-agent/`, and the root will expose a `.claude-plugin/marketplace.json` manifest named `courseagent`.

Target user flow:

```text
/plugin marketplace add zaxliu/CourseAgent
/plugin install course-agent@courseagent
```

## Goals

- Support GitHub-hosted marketplace distribution instead of local symlink installation.
- Keep the install flow minimal and stable.
- Match the marketplace layout used by public Claude Code marketplace repositories.
- Preserve the existing plugin behavior and commands.

## Non-Goals

- Publishing to Anthropic's official marketplace.
- Adding more plugins to this repository right now.
- Changing the plugin's command semantics.
- Adding new runtime dependencies or MCP integrations.

## Recommended Approach

Use the repository as a marketplace root and move the plugin into `plugins/course-agent/`.

### Why this approach

- It matches public marketplace examples from Anthropic-managed repositories.
- It avoids relying on ambiguous root-level dual-use behavior where one directory acts as both marketplace and plugin.
- It leaves room for future expansion if additional plugins are added later.

## Alternatives Considered

### 1. Root repository acts as both marketplace and plugin

Keep the current root-level `.claude-plugin/plugin.json` and add a root-level `marketplace.json` that references the repository root.

Rejected because the compatibility risk is higher and there is no strong primary-source example showing this structure as the recommended pattern.

### 2. Separate marketplace repository

Create a second repository that only contains `.claude-plugin/marketplace.json` and points at this plugin repository.

Rejected because it adds unnecessary operational overhead and makes installation and maintenance more fragmented.

## Target Structure

```text
CourseAgent/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── course-agent/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── commands/
│           ├── course-design.md
│           └── learn.md
├── .github/
│   └── workflows/
│       └── ci.yml
├── README.md
└── LICENSE
```

## Component Design

### Marketplace Manifest

Add root-level `.claude-plugin/marketplace.json` with:

- marketplace name: `courseagent`
- version and description metadata
- one plugin entry named `course-agent`
- `source` set to `./plugins/course-agent`
- optional author/homepage metadata for discoverability

The marketplace name is intentionally aligned with the user-facing install suffix:

```text
course-agent@courseagent
```

### Plugin Manifest

Move the current plugin manifest to:

`plugins/course-agent/.claude-plugin/plugin.json`

Adjust manifest content as needed:

- plugin name becomes `course-agent`
- command paths remain relative to the plugin root, so they stay `./commands/course-design.md` and `./commands/learn.md`
- description can remain essentially the same

### Command Files

Move existing command markdown files into:

- `plugins/course-agent/commands/course-design.md`
- `plugins/course-agent/commands/learn.md`

No behavior changes are planned in this migration. Only file location changes.

### README

Rewrite installation guidance so GitHub marketplace install is the primary path.

The README should:

- explain that this repo is a Claude Code marketplace
- show the two install commands
- refer to plugin name `course-agent`
- remove the local symlink flow as the main installation path
- optionally retain a brief developer/local-testing section if useful

### CI Workflow

Update CI validation to point at the plugin manifest under `plugins/course-agent/.claude-plugin/plugin.json`.

Validation should still cover:

- manifest JSON validity
- presence of referenced command files
- frontmatter checks for command markdown files

Markdown lint paths should also point at the moved command files.

## Data Flow

### Installation Flow

1. User adds the GitHub repository as a marketplace.
2. Claude Code reads root `.claude-plugin/marketplace.json`.
3. Claude Code resolves `course-agent` to `./plugins/course-agent`.
4. Claude Code installs the plugin from that subdirectory.
5. Command files become available under the installed plugin namespace.

### Update Flow

1. Repository changes are pushed to GitHub.
2. User updates the marketplace metadata in Claude Code.
3. User updates or reinstalls the plugin as needed through Claude Code.

## Error Handling And Risks

### Path breakage after move

Risk:
CI or marketplace resolution may still refer to old root paths.

Mitigation:
Update every path-bearing file together:

- root marketplace manifest
- plugin manifest
- workflow validation commands
- README examples

### Plugin name mismatch

Risk:
Users may try installing `CourseAgent@courseagent` instead of `course-agent@courseagent`.

Mitigation:
Use `course-agent` consistently in marketplace manifest and README examples.

### Marketplace naming confusion

Risk:
Repository name is `CourseAgent` while marketplace install suffix is lower-case `courseagent`.

Mitigation:
Document the exact installation commands verbatim in README.

## Testing Plan

### Static Validation

- Parse marketplace JSON successfully.
- Parse plugin JSON successfully.
- Verify every command path referenced by plugin JSON exists.
- Verify command files still contain required frontmatter.

### Installability Sanity Check

If local Claude plugin tooling is available, validate the marketplace layout using the repository as a marketplace source before relying on GitHub install.

### Regression Scope

- Command file contents remain unchanged.
- Plugin version remains valid after relocation.
- CI still passes on `main`.

## Rollout Plan

1. Add root marketplace manifest.
2. Move plugin files under `plugins/course-agent/`.
3. Update plugin manifest name and retained relative command references.
4. Update CI paths.
5. Rewrite README install instructions.
6. Run local validation matching CI checks.
7. Commit and push migration.

## Open Questions

None for this migration. The user has already selected:

- repository doubles as marketplace root
- marketplace name is `courseagent`
- preferred structure is a marketplace root with plugin under `plugins/course-agent/`
