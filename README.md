# Wintersun – SkyrimNet Integration

SkyrimNet integration for [Wintersun – Faiths of Skyrim](https://www.nexusmods.com/skyrimspecialedition/mods/22506). Narrates your character's religious life and brings your deity to life during prayer.

## Features

### Prayer narration
When you kneel to pray, nearby NPCs hear a narration referencing your deity:
> *{player} kneels and closes their eyes, lips moving in silent prayer to Stendarr.*

Falls back to a generic line if no deity is chosen.

### Shrine worship narration
When you interact with a Wintersun shrine, nearby NPCs hear:
> *{player} approaches the shrine and bows their head in reverence to Talos.*

### Character bio
The SkyrimNet character profile includes your deity and rank:
> {player} worships Stendarr. He is a Devotee, having earned full divine favour.

### Deity virtual NPC
When you pray, your deity becomes available as a conversation partner for the duration of the prayer. Each of the 52 Wintersun deities has a unique default voice type and personality prompt. Configurable via the SkyrimNet WebUI.

### Shrine communion
Activating any deity's shrine starts a brief conversation with that deity — even if they are not your followed deity. Duration and enable/disable are configurable via the SkyrimNet WebUI.

## Requirements

- [Wintersun – Faiths of Skyrim](https://www.nexusmods.com/skyrimspecialedition/mods/22506)
- SkyrimNet
- SKSE
- [PO3 Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)

## Installation

Install with a mod manager (MO2 / Vortex), or extract directly into your `Skyrim Special Edition/Data/` folder. Enable `WSN_SkyrimNet_Integration.esp` in your load order. The plugin is ESL-flagged and does not consume a load order slot.

## Configuration

Settings are available in the SkyrimNet WebUI under the **Wintersun Integration** plugin:

| Setting | Description |
|---|---|
| **Voice Type Override** | Override all deity voices with a single voice type (e.g. `MaleEvenToned`). Leave empty to use per-deity defaults. |
| **Require Devotee Status** | When enabled, the deity virtual NPC only activates for Devotees. Disable to allow all worshippers to commune. Default: on. |
| **Allow Shrine Communion** | When enabled, activating any shrine starts a brief conversation with that deity. Default: on. |
| **Shrine Communion Duration** | How many seconds the shrine deity stays active. Default: 120. |
| **Debug Mode** | Show in-game debug notifications. For troubleshooting only. Default: off. |

## Known Issues

**Deity persona prompt not applied** — A SkyrimNet issue causes save-specific bios to override mod-provided character prompts with blank content, so deities speak without unique personality for now.

> **Workaround:** Copy `wsn_deity_virtual.prompt` from `SKSE/Plugins/SkyrimNet/prompts/characters/` into `SKSE/Plugins/SkyrimNet/prompts/_saves/<your_save_id>/characters/`. Your save ID is the folder name inside `_saves/`.

## Planned

- Deity switching and abandonment narration
- SkyrimNet actions to increase/decrease deity favour
- Expanded deity lore and tenets for richer prayer dialogue
