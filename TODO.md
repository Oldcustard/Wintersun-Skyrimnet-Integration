# Wintersun-SkyrimNet Integration — TODO

- [x] Convert ESP to ESPFE (ESL-flagged) to save load order slot
- [x] Investigate event-based prayer end detection — not possible; polling reduced to 5s intervals
- [x] Fix deity-switch narration trigger — should only fire when the player accepts the change, not on offer
- [ ] **Deity personality database** — fill `wintersun_deities.md` reference (Description, Tenets, Boons, Personality for all 52 deities), add Papyrus String[] arrays for persona/tenets, restructure prompt to use `get_script_property` lookups instead of if/elif chain (Phase 2 of `.claude/plans/deity-personality-database.md`)
- [x] **Deity virtual NPC prompt** — restructured to `{% block summary %}` / `{% block personality %}` / `{% block speech_style %}` format; validated; included in Full package
- [x] **Manifest settings** — `manifest.yaml` with debug toggle and voice type override; Papyrus reads via `SkyrimNetApi.GetConfigBool`/`GetConfigString`; voice override + per-deity voice now resolve via `ResolveVoice()` and always passed in `HandlePrayerStart()` (fixes deity-switch voice bug)
- [ ] Fix deity-switch and deity-abandonment narration — SkyrimNet's active_effect events don't detect Wintersun's Tenet effects; needs Papyrus-side DirectNarration approach (deferred from v2.0.0)
- [ ] Add SkyrimNet actions to increase/decrease favour with the current deity
- [x] Config option — whether deities require Devotee status to be communicated with (vs. allowing all worshippers)
- [ ] Handle saved memories when switching deities — determine whether/how SkyrimNet memories should be cleared or scoped per-deity on deity switch
- [x] Config option — allow communing with non-followed deities when interacting with their shrines
- [ ] Bio override issue — save-specific prompts in `_saves/<save_id>/characters/` overwrite mod-provided deity persona prompt; user-side workaround documented in release post (copy `wsn_deity_virtual.prompt` into save folder manually); awaiting upstream SkyrimNet fix
