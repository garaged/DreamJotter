# M12.1 Character and Location Management

Status: specified

## Purpose

Provide safe lifecycle and bulk-edit workflows for canonical character and location profiles while keeping screenplay edits semantic, previewable, command-backed, snapshot-protected, Unicode-safe, and persistent.

## Profile Lifecycle Contract

Character and location records gain an optional archive timestamp. A missing timestamp means active. Existing package files that do not contain the field decode as active without migration.

Archive and restore are reversible command operations. Delete is irreversible from current project state and requires explicit user confirmation before command construction. Delete does not rewrite screenplay text automatically.

## Duplicate Merge Contract

A merge request names one surviving profile and one or more source profile IDs.

Before mutation the command engine must:

1. verify all profiles exist and are the same profile kind;
2. reject a source list containing the surviving ID;
3. create a project snapshot;
4. combine nonempty notes deterministically without dropping unique text;
5. remap detected-profile matches to the survivor;
6. remove merged source profiles;
7. mark the survivor source as `merged` and update its timestamp.

Merge does not silently rewrite screenplay text. The writer may run bulk rename separately after reviewing its preview.

## Bulk Rename Preview

A preview is read-only and contains:

- profile kind;
- profile ID;
- current display name;
- proposed display name;
- affected screenplay element indexes;
- original and replacement text for each affected element;
- affected scene headings for location renames;
- diagnostics for empty names, no matches, or normalized-key conflicts.

Character rename matches semantic `characterCue` elements by Unicode-aware normalized key. Location rename changes only the location segment of semantic `sceneHeading` elements and preserves interior/exterior prefix and time-of-day text.

## Bulk Rename Apply

Apply requires a command containing the preview identity and proposed name. The engine recomputes the preview against current project state and rejects stale or mismatched previews.

Apply must create a snapshot before changing:

- the canonical profile display name and normalized key;
- matching semantic screenplay elements;
- derived scenes and character projections;
- detected-profile resolution links;
- linked scene-card character or location metadata where it references the renamed normalized key.

## Command Types

M12.1 adds command types for:

- archive profile;
- restore profile;
- delete profile;
- merge profiles;
- bulk rename profile.

Delete, merge, and bulk rename set `requiresSnapshot` to true. Archive and restore remain command-backed but do not require a snapshot because they are directly reversible.

## Persistence

Archived timestamps and all accepted profile mutations persist through existing character and location package sections. The package format version remains compatible because new lifecycle fields are optional.

## UI Boundary

This slice requires core and view-model behavior plus minimal management presentation. Confirmation and preview are UI responsibilities; mutation remains in `CommandEngine`. The editor selection must not change until the user explicitly navigates to an affected preview item.
