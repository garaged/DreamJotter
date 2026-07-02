# Milestone 11 Traceability Matrix Extension

This extension supplements the primary DreamJotter traceability matrix for Milestone 11.

| Product requirement ID | Milestone | Feature area | Spec document | Acceptance document | Data contract document | Executable spec file | Implementation module | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| M11-FDX-INTEROPERABILITY | M11 | FDX interchange foundation | `docs/milestones/milestone-11-fdx-interoperability.md` | `docs/acceptance/milestone-11-acceptance.md` | `docs/data-contracts/core-domain-model.md`, `docs/data-contracts/screenplay-element-kinds.md` | `Tests/DreamJotterExecutableSpecs/FDXInterchangeExecutableSpecs.swift` | FDXInterchange, FDXDiagnostic, FDXImportResult, FDXExportResult | implemented | Portable deterministic FDX subset with diagnostics and safe malformed-input handling. |
| M11-FDX-EXPORT | M11 | FDX screenplay export | `docs/milestones/milestone-11-fdx-interoperability.md` | `docs/acceptance/milestone-11-acceptance.md` | `docs/data-contracts/screenplay-element-kinds.md` | `Tests/DreamJotterExecutableSpecs/FDXInterchangeExecutableSpecs.swift` | FDXInterchange | implemented | Maps supported screenplay roles to UTF-8 Final Draft XML and warns when internal-only elements are omitted. |
| M11-FDX-IMPORT | M11 | FDX screenplay import | `docs/milestones/milestone-11-fdx-interoperability.md` | `docs/acceptance/milestone-11-acceptance.md` | `docs/data-contracts/core-domain-model.md`, `docs/data-contracts/screenplay-element-kinds.md` | `Tests/DreamJotterExecutableSpecs/FDXInterchangeExecutableSpecs.swift` | FDXInterchange, FDXImportResult | implemented | Maps supported FDX paragraphs to semantic elements, preserves unknown types, and rebuilds scene and character projections. |

## Boundary Decision

FDX is an interchange format only. `.dreamjotter` remains canonical storage, and application-level project integration is deferred to a later milestone.
