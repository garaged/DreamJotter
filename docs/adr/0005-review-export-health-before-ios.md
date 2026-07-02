# ADR 0005: Review, Export, and Health Before iOS Expansion

Status: Accepted
Date: 2026-07-01

## Context

DreamJotter now has a macOS writing workflow with document lifecycle, editor usability, and project-object organization. The next major product risk is writer trust: writers need confidence that their work can be reviewed, exported, backed up, restored, and shared before DreamJotter expands to more Apple platforms.

## Decision

Milestone 9 prioritizes export, review, script health, and backup/restore before iOS or iPadOS expansion.

## Rationale

- Writers trust tools that let them get work out of the app in practical formats.
- Backup and restore reduce fear of losing work before more platforms multiply lifecycle complexity.
- Review Mode can improve script inspection without introducing accidental editing risk.
- Script Health Report can provide useful non-AI feedback using existing semantic data.
- A basic PDF is acceptable now because readable sharing is more important than production-perfect pagination at this stage.

## Consequences

- iOS and iPadOS remain deferred while Mac trust workflows mature.
- PDF output may be intentionally basic and must document its limits.
- Review Mode must remain read-only and should reuse existing navigation state.
- Backup/restore must validate data and protect dirty work before replacing state.
- Export presets must avoid leaking internal metadata by default.

## Tradeoffs

- This delays platform expansion but reduces the risk of spreading immature document workflows across more targets.
- This adds export/review surface area before visual polish, but the work is testable and grounded in portable data.
- Basic PDF output may disappoint production users, so production pagination remains explicitly deferred.
