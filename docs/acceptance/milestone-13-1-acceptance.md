# M13.1 Screenplay Paragraph Semantics Acceptance

## Implemented

- Canonical `ScreenplayParagraphType` stored on `ScriptElement`.
- Backward-compatible decoding for projects created before M13.1.
- Blank paragraphs terminate inferred dialogue context.
- Explicit markers override inference and round-trip through DreamJotter text export.
- Supported types: scene heading, action, character introduction, character cue, dialogue, parenthetical, transition, shot, section, synopsis, montage, note, and page break.
- Script workspace right column shows the current paragraph type and allows changing it.
- PDF layout uses canonical paragraph semantics.
- Print Script enforces page and paragraph numbers without line numbers.

## Automated coverage

- Dialogue-context boundary regression.
- Explicit action override after a character cue.
- Full paragraph-type parse/export round trip.
- Paragraph inspector selection and mutation.
- PDF role and width selection from canonical semantics.

## Manual verification

- Move the cursor through each paragraph type and verify the right inspector updates.
- Change the paragraph after a character cue from Dialogue to Action and confirm full-width PDF output.
- Verify a genuine Dialogue paragraph remains in the dialogue column.
- Verify Section and Montage are visible in the inspector and use body-width PDF layout.
- Verify Print Script contains page and paragraph numbers but no line labels.

## Validation commands

```bash
swift test
swift build --product DreamJotterMac
```
