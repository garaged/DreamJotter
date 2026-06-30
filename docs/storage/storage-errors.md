# Storage Errors

## Purpose

This document defines storage diagnostic categories for `.dreamjotter` package operations. Storage errors must be specific, recoverable where possible, and safe: the app must not silently invent canonical project state when package data is missing or invalid.

## Error Shape

Future implementations should represent storage diagnostics with portable data:

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `code` | string | Yes | Stable error code. |
| `severity` | string | Yes | `info`, `warning`, `recoverable`, or `fatal`. |
| `path` | string | No | Package-relative failing path. |
| `message` | string | Yes | Friendly diagnostic message. |
| `recoverySuggestion` | string | No | Suggested next step. |
| `underlyingCode` | string | No | Platform or parser diagnostic code if safely portable. |

Example:

```json
{
  "code": "missingRequiredFile",
  "severity": "fatal",
  "path": "project.json",
  "message": "The project file is missing.",
  "recoverySuggestion": "Restore from a snapshot or backup archive."
}
```

## Error Codes

| Code | Severity | Meaning | Expected Behavior |
| --- | --- | --- | --- |
| `missingManifest` | fatal | `manifest.json` is missing. | Do not open as editable package. Offer recovery/backup guidance. |
| `missingRequiredFile` | fatal | Required file such as `project.json` or `screenplay.json` is missing. | Do not invent state. Report path. |
| `missingOptionalFile` | warning | Optional file listed in manifest is missing. | Load core project if safe and report degraded section. |
| `invalidJSON` | fatal or recoverable | JSON parse failed. | Report path; load unaffected sections only if safe. |
| `invalidSchema` | fatal or recoverable | JSON parsed but required fields or types are invalid. | Report field/path diagnostics. |
| `unsupportedFormatVersion` | fatal | Package major format version is newer than supported. | Reject or open read-only without mutation. |
| `unsupportedSectionVersion` | recoverable | Section schema is newer than supported. | Preserve section if possible; disable affected feature. |
| `brokenReference` | warning or recoverable | A record references a missing target. | Preserve referring record and report diagnostic. |
| `checksumMismatch` | recoverable or fatal | Optional checksum does not match file content. | Treat affected section as suspect; avoid mutation until user decides. |
| `permissionDenied` | fatal | Package file cannot be read or written. | Report operation and path; do not retry destructively. |
| `partialWrite` | recoverable or fatal | Write failed before package update completed. | Preserve prior valid files where possible; report recovery state. |
| `atomicReplaceFailed` | fatal | Atomic replacement failed. | Do not mark save successful. |
| `snapshotMissing` | fatal | Requested snapshot directory or metadata is missing. | Do not restore. |
| `snapshotInvalid` | fatal | Snapshot files are invalid or incomplete. | Do not restore. |
| `restoreFailed` | fatal | Snapshot restore could not complete. | Preserve current project where possible and report rollback state. |
| `attachmentMissing` | warning | Attachment metadata references missing file. | Load project; mark attachment unavailable. |
| `exportWriteFailed` | recoverable | Export artifact could not be written. | Do not alter canonical project data. |
| `indexInvalid` | info | Rebuildable index is missing or invalid. | Discard/rebuild index. |
| `unknownSection` | info | Package contains unknown section. | Preserve where possible and continue if required files are valid. |

## Friendly Message Rules

- Messages should identify the affected package area without blaming the user.
- Fatal errors should say what cannot continue.
- Recoverable errors should explain what data may be unavailable.
- Suggestions should prefer restoring from snapshot or backup over destructive repair.

## Given/When/Then Examples

- Given `project.json` is missing, when load runs, then `missingRequiredFile` is emitted with path `project.json` and no project state is invented.
- Given `screenplay.json` is invalid JSON, when load runs, then `invalidJSON` is emitted with path `screenplay.json`.
- Given the package format version is unsupported, when load runs, then `unsupportedFormatVersion` is emitted and no migration writes occur.
- Given an attachment file is missing, when load runs, then `attachmentMissing` is emitted and the project can still load if canonical files are valid.
- Given `indexes/search-index.json` is corrupt, when load runs, then `indexInvalid` is emitted and the index can be rebuilt.

## Recovery Policy

- Do not repair canonical package data automatically without user consent.
- Do not delete unknown sections during recovery.
- Do not overwrite damaged files during inspection.
- Prefer snapshot restore or backup archive restore for canonical corruption.
- Preserve valid sections where safe.
- Do not use SwiftData cache to replace missing canonical package content.

## Platform Neutrality

Storage diagnostics must use portable string codes and package-relative paths. Platform-specific error details may be attached as optional diagnostics, but canonical recovery logic must not depend on Apple-only error types.

## Related Specs

- `docs/storage/dreamjotter-package-format.md`
- `docs/data-contracts/serialization-rules.md`
- `docs/adr/0002-local-first-dreamjotter-package.md`
