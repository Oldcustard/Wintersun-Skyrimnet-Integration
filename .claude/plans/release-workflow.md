# Plan: Release Workflow

## Context

When the user requests a version release (e.g. "release v2.1.0"), a standardized workflow ensures debug is disabled, docs are updated, and packages are rebuilt consistently.

## Release Steps

Execute in order:

### 1. Disable debug
- Set `bDebugMode = False` in `Scripts/Source/WSN_SkyrimNet_QuestScript.psc`

### 2. Compile scripts
- `papyrus compile` all modified `.psc` files

### 3. Update CHANGELOG.md
- Add new `## [X.Y.Z] - YYYY-MM-DD` entry at top
- Sections: `Added`, `Fixed`, `Changed`, `Removed` — only include non-empty sections
- Review diff since last version to identify changes
- Keep entries concise

### 4. Update README.md
- Feature list must match current package contents
- Verify links and requirements are current

### 5. Update discord_op.md
- Full mod description for Discord opening post
- Must be under 2000 characters (Discord limit), Discord-compatible markdown
- Must match README feature list

### 6. Create release-vX.Y.Z.md
- User-facing Discord post announcing what changed in this version specifically
- Under 2000 characters
- Sections: What's new / Fixes / Also note / Requirements
- Only user-visible changes — no internal technical details

### 7. Rebuild packages

**Full** (`Wintersun-SkyrimNet-Integration.zip`):
- `Scripts/*.pex` → `Scripts/`
- `Seq/*.seq` → `Seq/`
- Working triggers only → `SKSE/Plugins/SkyrimNet/config/triggers/`
- `Prompts/0350_wintersun.prompt` → `SKSE/Plugins/SkyrimNet/prompts/submodules/character_bio/`
- `WSN_SkyrimNet_Integration.esp` → root
- Exclude: deity persona prompt (broken), switch/abandonment triggers (broken)

**Lite** (`Wintersun-SkyrimNet-Integration-Lite.zip`):
- All triggers (including broken for reference) → `SKSE/Plugins/SkyrimNet/config/triggers/`
- `Prompts/0350_wintersun.prompt` → `SKSE/Plugins/SkyrimNet/prompts/submodules/character_bio/`

### 8. Verify
- Confirm no debug in scripts: `grep "bDebugMode = True"` returns nothing
- Verify package contents match expectations
- Release notes accurate against actual changes

## Files

- `Scripts/Source/WSN_SkyrimNet_QuestScript.psc` — debug toggle
- `CHANGELOG.md` — version entry
- `README.md` — feature list
- `discord_op.md` — full mod description (Discord OP)
- `release-vX.Y.Z.md` — version-specific Discord post (new file per release)
- `Wintersun-SkyrimNet-Integration.zip` — rebuilt
- `Wintersun-SkyrimNet-Integration-Lite.zip` — rebuilt
