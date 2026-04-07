# Plan: Deity Personality Database

## Context

The deity virtual NPC prompt (`wsn_deity_virtual.prompt`) has 52 if/elsif blocks for per-deity persona text, and `WSN_SkyrimNet_QuestScript.psc` uses a single `DeityVoiceID` for all deities. The reference file (`wintersun_deities.md`) is a skeleton with domains filled but everything else TODO.

Goal: (1) establish reference as master documentation, (2) store per-deity voice types, (3) architecture for injecting deity data (tenets, persona) into the prompt via Papyrus arrays instead of the if/elif chain.

### Prerequisite Bug

The prompt uses `elsif` throughout, but SkyrimNet's Inja engine requires `elif`. This is a **separate task** to fix before this work begins.

## Architecture: Three-Layer System

```
wintersun_deities.md          ← Master reference (human-edited, version-controlled)
        │
        ▼ manual transcription
WSN_SkyrimNet_QuestScript.psc ← Runtime: String[] arrays indexed by worshipID
        │
        ▼ get_script_property + at()
wsn_deity_virtual.prompt      ← Template: reads all deity data from Papyrus
```

### Layer 1: Reference File (`wintersun_deities.md`)

Add a **Voice Type** field to each deity entry. All other fields (Description, Tenets, Boons, Personality) get filled as part of this work:

```markdown
### Akatosh
- **Domain:** Time, endurance, invincibility, everlasting legitimacy
- **Voice Type:** maleelder
- **Description:** <filled>
- **Tenets:** <filled>
- **Follower Boon:** <filled>
- **Devotee Boon:** <filled>
- **Personality:** <filled>
```

This file is the single source of truth. Updates are made here first, then transcribed into Papyrus.

### Layer 2: Papyrus Quest Script

Add String[] properties to `WSN_SkyrimNet_QuestScript.psc`, all indexed by worshipID (0–51):

| Property | Content | Phase |
|---|---|---|
| `String[] WSN_DeityVoiceID` | Default voice type per deity | **Now** |
| `String[] WSN_DeityPersona` | Combined identity + personality text | Phase 2 |
| `String[] WSN_DeityTenets` | Tenets (what earns/loses favour) | Phase 2 |

**Voice lookup in HandlePrayerStart():**
```papyrus
String deityVoice = DeityVoiceID  ; global default
If worshipID >= 0 && worshipID < WSN_DeityVoiceID.Length
    String perDeityVoice = WSN_DeityVoiceID[worshipID]
    If perDeityVoice != ""
        deityVoice = perDeityVoice
    EndIf
EndIf
SkyrimNetApi.UpdateVirtualNPC(VIRTUAL_NPC_NAME, deityName, deityVoice, "", "")
```

**Phase 2** (after reference is populated): Add persona and tenets arrays. Initialize in `OnInit()` or set via ESP properties.

### Layer 3: Prompt Template

**Phase 2** replaces the 52-block if/elif chain with Papyrus lookups:

```
{% set worshipID = get_script_property("WSN_TrackerQuest_Quest", "wsn_trackerquest_quest", "WorshipID") %}
{% set deityNames = get_script_property("WSN_TrackerQuest_Quest", "wsn_trackerquest_quest", "WSN_DeityName") %}
{% set deityName = at(deityNames, worshipID) %}

{% set personas = get_script_property("WSN_SkyrimNet_QuestScript", "WSN_SkyrimNet_Quest", "WSN_DeityPersona") %}
{% set tenets = get_script_property("WSN_SkyrimNet_QuestScript", "WSN_SkyrimNet_Quest", "WSN_DeityTenets") %}
{% set persona = at(personas, worshipID) %}
{% set tenet = at(tenets, worshipID) %}

You are {{ deityName }}, an ancient and powerful deity of Tamriel...
{{ persona }}
Your sacred tenets: {{ tenet }}
Keep your responses brief and divine in tone...
```

This shrinks the prompt from ~116 lines to ~20 lines.

## Implementation: Phase 1 (This Task)

### Voice Type Group Defaults

| Category | Voice ID | Deities |
|---|---|---|
| Aedra (male) | `maleelder` | Akatosh, Arkay, Julianos, Talos, Zenithar, Shor |
| Aedra (female) | `femaleeventoned` | Dibella, Kynareth, Mara |
| Daedric (male) | `maleevilemperor` | Boethiah, Clavicus Vile, Hermaeus Mora, Hircine, Jyggalag, Malacath, Mannimarco, Mehrunes Dagon, Molag Bal, Peryite, Sanguine, Sheogorath |
| Daedric (female) | `female sultry` | Azura, Mephala, Meridia, Namira, Nocturnal, Vaermina |
| Elven | `maleelfhaughty` | Auriel, Phynaster, Syrabane, Xarxes, Magnus, Trinimac |
| Bosmer/Khajiit | `malecommoner` | Baan Dar, Rajhin, Jephre, Z'en, The Riddle'Thar |
| Redguard | `malecommander` | HoonDing, Tall Papa, Satakal |
| Redguard (female) | `femaleeventoned` | Leki, Morwha |
| Misc | `malecommoner` | Ebonarm, Sai, Sithis, St. Alessia, The All-Maker, The Hist, The Magna-Ge, The Old Ways |

*(Exact voice IDs to be confirmed by listing available Skyrim voice types)*

### Steps

1. **Fill reference file** — Add Voice Type field to each deity in `wintersun_deities.md`
2. **Update Papyrus script** — Add `String[] Property WSN_DeityVoiceID Auto` to quest script, update `HandlePrayerStart()` with voice lookup
3. **Compile script** — `papyrus compile`
4. **Auto-fill properties** — `esp auto-fill`
5. **Set voice array values** — Set 52 elements via toolkit `esp set-property`
6. **Package zip** — Rebuild distribution

### Steps (Phase 2 — Future)

7. **Fill remaining reference fields** — Description, Tenets, Boons, Personality for all 52 deities
8. **Add persona + tenets arrays** to quest script
9. **Restructure prompt** — Replace if/elif chain with Papyrus lookups
10. **Validate** — MCP `validate_prompt` on the restructured template

## Files

- `wintersun_deities.md` — Add Voice Type field
- `Scripts/Source/WSN_SkyrimNet_QuestScript.psc` — Voice array + lookup logic
- `Prompts/characters/wsn_deity_virtual.prompt` — Phase 2 restructure (not this task)

## Verification

1. Compile Papyrus script — `papyrus compile`
2. Auto-fill quest properties — `esp auto-fill`
3. Set 52 voice values — `esp set-property`
4. Validate prompt still works — MCP `validate_prompt` (with elsif→elif fix applied separately)
5. In-game test: pray to deities in different voice groups, confirm voice changes
