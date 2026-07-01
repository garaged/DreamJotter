# TextKit/AppKit Editor Adapter Plan

Status: implemented foundation
Milestone: M5
Traceability ID: EDITOR-TEXTKIT-ADAPTER-MAC

## Purpose

This plan defines the first macOS TextKit editor adapter for DreamJotter. The adapter improves the writing surface while preserving the existing portable screenplay architecture.

TextKit is a UI editing adapter only. The semantic screenplay model, `.dreamjotter` package data, Fountain import/export, parser diagnostics, and script analysis remain owned by `DreamJotterCore`.

## Scope

- Wrap `NSTextView` in a SwiftUI `NSViewRepresentable`.
- Bind plain screenplay text to the existing project document view model.
- Keep SwiftUI `TextEditor` available as a fallback during transition.
- Use a monospaced screenplay-friendly editor font.
- Enable multiline editing.
- Use native text view undo where practical.
- Preserve selection when external bound text changes where reasonable.
- Keep parser refresh, save, load, health report, and Fountain export behavior unchanged.

## Non-Goals

- No pagination.
- No production revision colors.
- No screenplay layout ruler.
- No TextKit-owned canonical storage.
- No `NSAttributedString` canonical project model.
- No direct mutation of `DreamJotterProject` from AppKit callbacks.
- No iPadOS or iOS TextKit/UIKit adapter yet.

## Architecture Rules

- `DreamJotterCore` must not import `SwiftUI`, `AppKit`, `UIKit`, `SwiftData`, or `CloudKit`.
- `NSTextView` lives only in the macOS app target.
- The adapter emits plain text edits through the same view-model path used by the SwiftUI fallback editor.
- The view model reparses text into semantic screenplay state using existing parser core.
- Save/load/export continue to use `.dreamjotter` package storage and `FountainIO`.

## Initial Behavior

Given an open project, when the writer switches to the TextKit editor, then the current screenplay text appears in an `NSTextView`.

Given the writer types in the TextKit editor, when text changes, then the document view model updates `scriptText` and reparses semantic scenes and characters.

Given the bound text changes outside the text view, when SwiftUI updates the adapter, then the adapter updates the text view and restores the prior selection when the range is still valid.

Given the user switches back to SwiftUI `TextEditor`, when they continue typing, then the same document view model, parsing, save, reopen, export, and health-report behavior remains available.

## Testability

Fragile UI automation is deferred. Current tests cover adapter-independent behavior:

- text updates flow through `ProjectDocumentViewModel.updateScriptText`
- semantic scene and character derivation still happens
- Fountain export still comes from parser-backed semantic text
- existing package save/load tests continue to pass

## Known Limitations

- Selection preservation is best-effort and text-range based.
- Undo is native `NSTextView` undo, not a cross-platform command history.
- There is no production screenplay pagination or line measurement.
- The fallback `TextEditor` remains available until TextKit behavior is mature.
