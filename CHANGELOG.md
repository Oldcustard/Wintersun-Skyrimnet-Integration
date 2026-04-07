# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
