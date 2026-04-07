# Wintersun – SkyrimNet Integration

SkyrimNet integration for **Wintersun – Faiths of Skyrim**. Narrates your character's religious life and brings your deity to life during prayer.

---

## What it does

**Prayer narration**
When you kneel to pray, nearby NPCs hear a narration referencing your deity:
> *{player} kneels and closes their eyes, lips moving in silent prayer to Stendarr.*

Falls back to a generic line if no deity is chosen.

**Shrine worship narration**
When you interact with a Wintersun shrine, nearby NPCs hear:
> *{player} approaches the shrine and bows their head in reverence to Talos.*

**Character bio — Religious Affiliation**
The SkyrimNet character bio includes your deity and rank:
> {player} worships Stendarr. He is a Devotee, having earned full divine favour.

**Deity virtual NPC — Commune during prayer**
When you pray as a Devotee, your deity becomes available as a conversation partner for the duration of the prayer. Speak with them directly.

Works for all 52 deities in Wintersun.

---

## Requirements

- [Wintersun – Faiths of Skyrim](https://www.nexusmods.com/skyrimspecialedition/mods/22506)
- SkyrimNet (with custom triggers support)
- Skyrim Script Extender (SKSE)
- [PO3 Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)

---

## Installation

Install with a mod manager (MO2 / Vortex), or extract directly into your `Skyrim Special Edition/Data/` folder. Enable `WSN_SkyrimNet_Integration.esp` in your load order. The plugin is ESL-flagged and does not consume a load order slot.

---

## Deity voice configuration

The deity virtual NPC defaults to the **Male Soldier** voice type (`malesoldier`). You can change the voice through the **SkyrimNet WebUI** — find the `wsn_deity` virtual NPC and update its voice setting. The change persists across prayer sessions.

---

## Notes

- The deity virtual NPC only activates during prayer and only when you are a **Devotee** (full favour). Followers cannot commune directly with their deity.

---

## Planned features

- Deity switching narration — narrate when the player accepts a new deity at a shrine
- Deity abandonment narration — narrate when a deity casts the player out for lost favour
- Per-deity default voice types
- Deity-specific personalities and speech styles (52 unique personas)
- Expanded deity lore and tenets for richer roleplay
- MCM configuration menu
- SkyrimNet actions to increase/decrease deity favour

Please feel free to leave any suggestions and feedback.
