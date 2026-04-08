# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

This is a Skyrim mod project workspace for **SkyrimNet Wintersun plugins**. The toolkit used to create and modify mods is located at `./spookys-automod-toolkit/`.

## Running the Toolkit

All commands run from the toolkit directory:

```bash
cd spookys-automod-toolkit
dotnet run --project src/SpookysAutomod.Cli -- <module> <command> [args] --json
```

**Always include `--json`** on every command — parse the `"success"` field before proceeding.

## Modules

| Module    | Purpose                          |
| --------- | -------------------------------- |
| `esp`     | Plugin files (.esp/.esl)         |
| `papyrus` | Papyrus scripts (.psc → .pex)    |
| `archive` | BSA/BA2 archives                 |
| `nif`     | 3D mesh inspection and editing   |
| `mcm`     | Mod configuration menus          |
| `audio`   | Voice/audio files (FUZ/XWM/WAV)  |
| `skse`    | SKSE C++ plugin projects         |

## Critical Rules

- **Always `--json`** — never skip it; human-readable output cannot be parsed
- **Check `success` field** before acting on results; don't assume success
- **Prefix EditorIDs** with the mod name (e.g., `Wintersun_Sword`, not `Sword`)
- **Use `--model`** for weapons/armor — they're invisible without it
- **Use `--effect`** for spells/perks — they do nothing without it
- **Run `papyrus status --json`** before any Papyrus operation
- **Use auto-fill** for vanilla property references instead of manual `set-property`
- **Compile scripts** after every edit — `.psc` files don't work without compilation
- **Stop on failure** — don't continue a workflow after a command fails

## Papyrus Headers

Headers must be in `spookys-automod-toolkit/skyrim-script-headers/` (copied from Creation Kit — not included due to copyright). The Setup Wizard (`SpookysAutomodSetup.exe`) can do this automatically.

Always compile with:
```bash
papyrus compile "./Scripts/Source/Script.psc" --output "./Scripts" --headers "./skyrim-script-headers" --json
```

## Auto-Fill (Key Workflow)

When scripts have properties referencing vanilla records (`LocTypeInn`, `GameHour`, `MQ101`, etc.), use auto-fill instead of setting them manually:

```bash
esp auto-fill "Mod.esp" --quest "QuestID" --script "ScriptName" \
  --psc-file "./Scripts/Source/Script.psc" \
  --data-folder "C:/path/to/Skyrim/Data" --json

# Bulk: process all scripts at once (5x faster)
esp auto-fill-all "Mod.esp" --script-dir "./Scripts/Source" --data-folder "C:/Skyrim/Data" --json
```

## Key Architecture (Quest Aliases)

Alias scripts are **not** stored on `QuestAlias` objects directly — they live in `QuestFragmentAlias` within `quest.VirtualMachineAdapter.Aliases[]`. `QuestFragmentAlias.Property.Object` must reference the quest's FormKey for Creation Kit visibility.

## Mod Architecture

### Virtual NPC Prayer System

When the player prays as a Devotee, their deity becomes a conversable virtual NPC:

1. **Prayer detection**: `WSN_SkyrimNet_PlayerAliasScript` uses PO3 Papyrus Extender's alias-based `OnMagicEffectApplyEx` to detect the Wintersun prayer effect
2. **NPC activation**: `WSN_SkyrimNet_QuestScript.HandlePrayerStart()` looks up the deity name via `wsn_trackerquest_quest`, calls `UpdateVirtualNPC` with resolved voice, then `EnableVirtualNPC`
3. **Prayer end**: 5-second polling via `RegisterForSingleUpdate` — checks `HasMagicEffect` on the player
4. **Deity persona prompt** (`wsn_deity_virtual.prompt`) — Uses `{% block summary %}`, `{% block personality %}`, `{% block speech_style %}` format with 52 deity-specific if/elif blocks inside each block. Deity name resolved via `get_script_property` + `at()` from Wintersun's `WSN_DeityName` array. Each block contains its own `{% set %}` lines for variable scoping.
5. **Voice**: `ResolveVoice(worshipID)` checks manifest override → per-deity voice from `WSN_DeityVoiceID[]` → fallback `DeityVoiceID`. Always passed in `HandlePrayerStart()` so deity switches update correctly. Voice type reference: `wintersun_deities.md`
6. **Settings**: `manifest.yaml` defines `debug.enabled` (bool), `voice.override` (string), and `require_devotee` (bool). Read via `SkyrimNetApi.GetConfigBool`/`GetConfigString`. No MCM needed.

### SkyrimNet Trigger YAMLs

- Triggers in `Triggers/` use Inja templates with `at()` for 0-based array indexing (not `loop.index` which is 1-based)
- Deity name lookup pattern: `get_script_property` → `at(deityNames, worshipID)`
- Inja uses `elif` (not `elsif` — this was a bug that broke the deity prompt)
- String literals in Inja filter args require double quotes
- Deity switch and abandonment triggers are **not working** — SkyrimNet's `active_effect` events cannot detect effects applied via Papyrus `AddSpell()`. These are excluded from packages.

### Packaging

One zip file built manually with Python's `zipfile` module (no build script):

- **Full** (`Wintersun-SkyrimNet-Integration.zip`): scripts, seq, ESP, working triggers, character bio prompt, deity persona prompt, manifest.yaml. Excludes: switch/abandonment triggers (broken).

File mapping into zip:
- `Scripts/*.pex` → `Scripts/`
- `Seq/*.seq` → `Seq/`
- `Triggers/*.yaml` (working only) → `SKSE/Plugins/SkyrimNet/config/triggers/`
- `Prompts/characters/*.prompt` → `SKSE/Plugins/SkyrimNet/prompts/characters/`
- `Prompts/0350_wintersun.prompt` → `SKSE/Plugins/SkyrimNet/prompts/submodules/character_bio/`
- `manifest.yaml` → `SKSE/Plugins/SkyrimNet/config/plugins/Wintersun Integration/manifest.yaml`
- `*.esp` → root

### ESPFE

The plugin (`WSN_SkyrimNet_Integration.esp`) is ESL-flagged (`0x200` header flag) and does not consume a load order slot.

## Plans

- `.claude/plans/deity-personality-database.md` — Deity personality database architecture (three-layer system: reference → Papyrus arrays → prompt template)
- `.claude/plans/release-workflow.md` — Version release workflow (debug disable, changelog, packaging, Discord posts)

## Documentation

- `spookys-automod-toolkit/CLAUDE.md` — toolkit internals, architecture, adding new commands
- `spookys-automod-toolkit/docs/llm-guide.md` — comprehensive workflows (quest aliases, audio, SKSE, patches)
- `spookys-automod-toolkit/docs/llm-init-prompt.md` — quick AI onboarding reference
- `spookys-automod-toolkit/.claude/skills/` — module-specific skill files
