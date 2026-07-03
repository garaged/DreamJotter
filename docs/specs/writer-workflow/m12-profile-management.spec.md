# M12.1 Character and Location Management

Status: implemented

## Purpose

Provide safe lifecycle, CRUD, search, and bulk-edit workflows for canonical character and location profiles while keeping screenplay edits semantic, previewable, command-backed, snapshot-protected, Unicode-safe, and persistent.

## Profile Lifecycle Contract

Archive state is stored as reserved project metadata inside the already persisted Pro-state envelope. Existing packages contain no archive markers and therefore decode every profile as active without migration or a package-format change.

Archive and restore are reversible command operations. Profile removal is irreversible from current project state and requires explicit user confirmation. Removal clears links to the removed profile but does not rewrite screenplay text automatically.

Persisted character and location profiles expose create, read, update, and confirmed delete operations in the macOS workspace. Detected screenplay entities remain derived projections and expose Convert and Ignore rather than independent CRUD.

## Search and Filtering Contract

Character and location workspaces provide Unicode-aware search across:

- persisted profile display name;
- persisted profile note;
- unresolved detected entity name.

The workspace exposes All, Profiles, and Detected scopes, visible result counts, clear actions, and explicit no-match states. Matching uses `TextNormalization.key`; stored graphemes are not rewritten during search.

## Duplicate Merge Contract

A merge request names one surviving profile and one or more source profile IDs.

Before mutation the command engine must:

1. verify all profiles exist and are the same profile kind;
2. reject an empty or invalid source list;
3. require explicit confirmation;
4. create a project snapshot;
5. combine nonempty notes deterministically without dropping unique text;
6. rewrite semantic screenplay references from source names to the survivor;
7. remap linked notes and scene-card metadata to the survivor;
8. remove merged source profiles;
9. mark the survivor source as `merged` and update its timestamp.

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

Apply creates a snapshot before changing:

- the canonical profile display name and normalized key;
- matching semantic screenplay elements;
- derived scenes and character projections;
- ignored-detection keys that would prevent the renamed profile from matching;
- linked scene-card character or location metadata.

## Command API

M12.1 adds `ProfileCommandRequest` and an overload of `CommandEngine.execute` for:

- archive profile;
- restore profile;
- remove profile;
- merge profiles;
- bulk rename profile.

Removal, merge, and bulk rename set `requiresSnapshot` to true. Archive and restore remain command-backed but do not require a snapshot because they are directly reversible.

## Persistence

Archive markers persist through the existing `pro.json` package section. Accepted profile, screenplay, note-link, scene-card, and snapshot mutations persist through their existing package sections. The package format version remains compatible.

## macOS Adapter Contract

The macOS workspace provides profile creation, editing, confirmed deletion, Unicode-aware search, detected-entity conversion, and ignore actions. Core lifecycle and bulk-rename behavior remains the source of truth. Metadata-only profile operations must not change editor cursor or scene-navigation state.
