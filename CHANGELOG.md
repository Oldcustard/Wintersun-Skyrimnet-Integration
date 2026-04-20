# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.1] - 2026-04-20

### Fixed

- Shrine communion now uses the shrine deity's personality and speech style instead of the player's followed deity

## [2.2.0] - 2026-04-19

### Added

- Shrine communion — activating any deity's shrine starts a brief conversation with that deity, even if they are not your followed deity. On by default; configurable via `allow_shrine_communion` and `shrine_communion_duration` manifest settings.

### Changed

- Sai removed from deity list (no longer present in Wintersun)

## [2.1.0] - 2026-04-07

### Added

- Per-deity voice types — all 52 deities have unique default voices (e.g. FemaleUniqueMeridia, MaleUniqueSheogorath)
- SkyrimNet manifest settings — configure debug mode, voice type override, and devotee requirement (`require_devotee`) in the SkyrimNet WebUI
- `require_devotee` setting — when disabled, all worshippers can commune with their deity during prayer (not just Devotees)
- Deity persona prompt — each deity has unique summary, personality, and speech style during prayer
  - **Note:** Currently non-functional due to a known SkyrimNet issue where save-specific bios override custom character prompts with blank content. Will work once fixed upstream.

### Fixed

- Deity voice now updates correctly when switching deities during prayer
- Voice type array initializes on existing save games (not just new games)
- Debug mode no longer defaults to True on fresh install — controlled via manifest setting

## [2.0.0] - 2026-04-06

### Added

- Character bio submodule (`0350_wintersun.prompt`) — adds deity name and rank (Follower/Devotee) to the SkyrimNet character profile
- Deity virtual NPC — commune with your deity during prayer (Devotee only); deity appears as a conversation partner with default voice (`malesoldier`), configurable via SkyrimNet WebUI
- `WSN_SkyrimNet_Integration.esp` — ESL-flagged plugin with quest, player alias, and compiled Papyrus scripts
- Player alias script with PO3 Papyrus Extender alias-based `OnMagicEffectApplyEx` for prayer detection

### Fixed

- Prayer narration deity lookup corrected (0-based indexing)

### Changed

- Virtual NPC display name always updated before enabling, ensuring deity changes are reflected
- Prayer end detection uses 5-second polling interval

## [1.0.0] - 2026-03-09

### Added

- Prayer narration trigger — narrates when the player kneels to pray, referencing their deity
- Shrine worship narration trigger — narrates when the player interacts with a Wintersun shrine
