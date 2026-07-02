# Detected Location Resolution Spec

Status: specified
Milestone: 8
Registry ID: DETECTED-LOCATION-RESOLUTION

## User Goal

Writers can convert locations detected from scene headings into reusable location profiles.

## Scope

- Detect locations from common scene heading forms.
- Exclude time-of-day values from location names.
- Show unresolved detected locations.
- Convert or ignore detections.
- Preserve Unicode text.

## Non-Goals

- No geolocation.
- No shooting location database.
- No automatic profile creation for every heading.

## Beginner Behavior

The app shows detected locations as cleanup suggestions and lets the writer convert or ignore each location.

## Pro Behavior

Future Pro Mode may add bulk resolution and production metadata. Milestone 8 only specifies deliberate single-item resolution.

## User-Facing Behavior

- `INT. COFFEE SHOP - DAY` detects `COFFEE SHOP`.
- Duplicate headings collapse to one unresolved location.
- Ignoring a location suppresses future unresolved prompts for that location.

## Acceptance Criteria

- `A-M8-DETECTED-LOCATION-001`
- `A-M8-DETECTED-LOCATION-002`
- `A-M8-DETECTED-LOCATION-003`
- `A-M8-DETECTED-LOCATION-004`
- `A-M8-DETECTED-LOCATION-005`

## Given/When/Then Examples

Given `EXT. PARK - NIGHT`, when detection runs, then `PARK` is detected and `NIGHT` is not.

Given `INT./EXT. CAR - CONTINUOUS`, when detection runs, then `CAR` is detected.

Given `INT. CAFETERIA - MORNING` appears twice, when unresolved detections display, then `CAFETERIA` appears once.

## Edge Cases

- Missing time-of-day suffix should still allow location extraction when syntax is clear.
- `DAY`, `NIGHT`, `MORNING`, `EVENING`, `CONTINUOUS`, `LATER` are time values, not locations.
- Duplicate normalized locations preserve canonical display text from first or preferred occurrence.

## Data Model Implications

Uses `DetectedLocation` for rebuildable location detections and ignore metadata. User-authored data lives in `LocationProfile`.

## Storage Implications

Ignored detected locations are project metadata. Detection results can be rebuilt from screenplay text.

## Command Implications

Convert and ignore operations should be explicit and dirty the project only when persistent metadata changes.

## UI Implications

Detected locations can appear in Locations pane, Dashboard cleanup counts, and suggestion sources.

## Testability Notes

Executable specs should cover heading parsing, time exclusion, duplicate collapse, conversion, ignore, Unicode preservation, and malformed heading safety.

## Platform Implications

Location detection belongs in portable services.

## Future Cross-Platform Implications

Future platforms should produce the same detected location set for a given screenplay.

## Security and Privacy Notes

Detection is local and does not contact external map or location services.

## Open Questions

- Should ignored detected locations suppress aliases or only exact normalized names?
