# Next-Stage Spec Plan

Status: specified
Branch: `next/m9-5-m9-6-m10-specs`

## Purpose

Collect the next DreamJotter planning sequence after the current uploaded M9.5 implementation.

This branch is intentionally spec-first. It should be used to review and refine the next stages before implementation commits begin.

## Proposed Sequence

### 1. M9.5 Closure QA

Spec:

- `docs/specs/release/m9-5-closure-qa.spec.md`

Purpose:

- Execute the Mac MVP manual QA checklist.
- Record validation results.
- Explicitly carry known limitations forward.

Exit condition:

- M9.5 is accepted for the Mac MVP baseline or blocking QA defects are filed.

### 2. M9.6 Restore UX Hardening

Specs:

- `docs/milestones/milestone-9-6-restore-ux-hardening.md`
- `docs/specs/export/restore-confirmation-flow.spec.md`

Purpose:

- Replace confirmation-required restore feedback with a full Save / Discard / Cancel restore flow.
- Preserve M6 dirty-state lifecycle rules.
- Keep restore validation non-destructive.

Exit condition:

- Dirty restore requires explicit user choice.
- Save failure blocks restore.
- Cancel preserves current state.
- Discard applies only validated backup data.

### 3. M10 Production PDF Export

Specs:

- `docs/milestones/milestone-10-production-pdf-export.md`
- `docs/specs/export/production-pdf-export.spec.md`

Purpose:

- Replace the basic M9 PDF adapter with deterministic, production-oriented screenplay PDF layout and pagination.
- Preserve existing export workflow and M9.5 picker UX.

Exit condition:

- Reader Copy, Print Script, and Contest Submission PDF outputs have specified layout, metadata policy, page numbering, diagnostics, and dirty-state preservation.

## Implementation Order Recommendation

1. Run M9.5 closure QA and capture the QA report.
2. Implement M9.6 restore UX hardening as a small stabilization milestone.
3. Start M10 with adapter-neutral layout planning tests before touching platform PDF rendering.

## Registry Follow-Up

After the specs are reviewed, add or update registry entries for:

- `M9-5-CLOSURE-QA`
- `M9-6-RESTORE-UX-HARDENING`
- `RESTORE-CONFIRMATION-FLOW`
- `M10-PRODUCTION-PDF-EXPORT`
- `PRODUCTION-PDF-EXPORT`

The existing registry already contains M9.5 implementation entries. This branch intentionally starts with human-readable specs before registry reshaping.
