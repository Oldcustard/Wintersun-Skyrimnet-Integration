# Wintersun-SkyrimNet Integration — TODO

- [x] Convert ESP to ESPFE (ESL-flagged) to save load order slot
- [x] Investigate event-based prayer end detection — not possible; polling reduced to 5s intervals
- [x] Fix deity-switch narration trigger — should only fire when the player accepts the change, not on offer
- [ ] **Deity personality database** — fill `wintersun_deities.md` reference, implement Papyrus String[] arrays for voice types / persona / tenets, restructure prompt to use `get_script_property` lookups (see plan: `.claude/plans/deity-personality-database.md`)
- [ ] **Fix deity virtual NPC prompt** — `elif` syntax fixed but personality formatting still broken; currently excluded from packages
- [ ] Fix deity-switch and deity-abandonment narration — SkyrimNet's active_effect events don't detect Wintersun's Tenet effects; needs Papyrus-side DirectNarration approach (deferred from v2.0.0)
- [ ] Implement MCM with configuration options (debug toggle, voice type, etc.)
- [ ] Add SkyrimNet actions to increase/decrease favour with the current deity
