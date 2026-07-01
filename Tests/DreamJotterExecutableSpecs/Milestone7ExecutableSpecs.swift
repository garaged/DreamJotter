import DreamJotterCore
import Foundation
import SpecSupport
import Testing

@Suite("Milestone 7 Executable Specs")
struct Milestone7ExecutableSpecs {
    @Test("Required editor usability specs exist")
    func requiredEditorUsabilitySpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-7-screenplay-editor-usability.md",
            "docs/acceptance/milestone-7-acceptance.md",
            "docs/specs/editor/smart-enter.spec.md",
            "docs/specs/editor/element-kind-cycling.spec.md",
            "docs/specs/editor/character-location-autocomplete.spec.md",
            "docs/specs/editor/scene-navigation-sync.spec.md",
            "docs/specs/editor/debounced-parsing.spec.md",
            "docs/specs/editor/basic-screenplay-line-styling.spec.md",
            "docs/data-contracts/editor-navigation-state.md",
            "docs/data-contracts/editor-suggestion.md",
            "docs/data-contracts/editor-parse-state.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Smart Enter predicts screenplay element transitions without UI adapters")
    func smartEnterPredictsScreenplayElementTransitionsWithoutUIAdapters() {
        #expect(EditorUsabilityService.nextKindAfterEnter(from: .sceneHeading) == .action)
        #expect(EditorUsabilityService.nextKindAfterEnter(from: .characterCue) == .dialogue)
        #expect(EditorUsabilityService.nextKindAfterEnter(from: .parenthetical) == .dialogue)
        #expect(EditorUsabilityService.nextKindAfterEnter(from: .dialogue, mode: .simple) == .action)
        #expect(EditorUsabilityService.nextKindAfterEnter(from: .transition) == .sceneHeading)
        #expect(EditorUsabilityService.nextKindAfterEnter(from: .unknown) == .action)
    }

    @Test("Tab cycling excludes scene headings and preserves line text")
    func tabCyclingExcludesSceneHeadingsAndPreservesLineText() {
        #expect(EditorUsabilityService.cycleKindAfterTab(from: .action) == .characterCue)
        #expect(EditorUsabilityService.cycleKindAfterTab(from: .characterCue) == .dialogue)
        #expect(EditorUsabilityService.cycleKindAfterTab(from: .dialogue) == .parenthetical)
        #expect(EditorUsabilityService.cycleKindAfterTab(from: .shot) == .noteReference)

        let unicodeLine = "NIÑA cruza la estación."
        let result = EditorUsabilityService.cycleLineKind(text: unicodeLine, currentKind: .action)
        #expect(result.text == unicodeLine)
        #expect(result.nextKind == .characterCue)
    }

    @Test("Scene heading suggestions classify common heading prefixes")
    func sceneHeadingSuggestionsClassifyCommonHeadingPrefixes() {
        let suggestions = EditorUsabilityService.sceneHeadingSuggestions(
            prefix: "INT.",
            scenes: [],
            replacementRange: EditorTextRange(location: 0, length: 4)
        )

        #expect(suggestions.contains {
            $0.type == .sceneHeading && $0.replacementText == "INT. "
        })
    }

    @Test("Character autocomplete returns canonical matching project characters")
    func characterAutocompleteReturnsCanonicalMatchingProjectCharacters() {
        let suggestions = EditorUsabilityService.characterSuggestions(
            prefix: "ele",
            characters: ["ELENA", "MARA", "ELENA"],
            replacementRange: EditorTextRange(location: 0, length: 3)
        )

        #expect(suggestions == [
            EditorSuggestion(
                id: "character-ELENA",
                type: .character,
                displayText: "ELENA",
                replacementText: "ELENA",
                textRange: EditorTextRange(location: 0, length: 3),
                priority: 0.75,
                source: .projectCharacters
            )
        ])
    }

    @Test("Location autocomplete derives parsed locations from scene headings")
    func locationAutocompleteDerivesParsedLocationsFromSceneHeadings() {
        let document = ScreenplayParser.parse("""
        INT. COFFEE SHOP - DAY

        The counter is empty.
        """)

        let suggestions = EditorUsabilityService.locationSuggestions(
            prefix: "INT. cof",
            scenes: document.scenes,
            replacementRange: EditorTextRange(location: 5, length: 3)
        )

        #expect(suggestions.first?.type == .location)
        #expect(suggestions.first?.replacementText == "COFFEE SHOP")
        #expect(suggestions.first?.source == .parsedLocations)
    }

    @Test("Time of day suggestions preserve canonical screenplay spelling")
    func timeOfDaySuggestionsPreserveCanonicalScreenplaySpelling() {
        let suggestions = EditorUsabilityService.sceneHeadingSuggestions(
            prefix: "INT. APARTMENT - ni",
            scenes: [],
            replacementRange: EditorTextRange(location: 16, length: 2)
        )

        #expect(suggestions.contains {
            $0.type == .timeOfDay && $0.replacementText == "NIGHT"
        })
    }

    @Test("Parse debounce waits for typing to settle")
    func parseDebounceWaitsForTypingToSettle() {
        let editDate = Date(timeIntervalSince1970: 10)

        #expect(!EditorUsabilityService.shouldParse(
            now: editDate.addingTimeInterval(0.1),
            lastEditAt: editDate
        ))
        #expect(EditorUsabilityService.shouldParse(
            now: editDate.addingTimeInterval(0.5),
            lastEditAt: editDate
        ))
    }

    @Test("Parse state tracks text and parsed revisions")
    func parseStateTracksTextAndParsedRevisions() {
        let changed = EditorUsabilityService.parseStateAfterTextChange(EditorParseState())
        let document = ScreenplayParser.parse("INT. ROOM - DAY")
        let refreshed = EditorUsabilityService.refreshedParseState(
            textRevision: changed.currentTextRevision,
            document: document,
            date: Date(timeIntervalSince1970: 20)
        )

        #expect(changed.currentTextRevision == 1)
        #expect(changed.lastParsedTextRevision == nil)
        #expect(refreshed.lastParsedTextRevision == 1)
        #expect(refreshed.sceneCount == 1)
        #expect(refreshed.elementCount == document.elements.count)
    }

    @Test("Clicking a scene requests navigation to its text range")
    func clickingSceneRequestsNavigationToItsTextRange() {
        let text = """
        INT. ROOM - DAY

        Quiet.

        EXT. STREET - NIGHT

        Rain.
        """
        let document = ScreenplayParser.parse(text)

        let state = EditorUsabilityService.navigationStateForScene(
            at: 1,
            text: text,
            scenes: document.scenes,
            parseRevision: 4
        )

        #expect(state.selectedSceneID == "scene-2")
        #expect(state.syncStatus == .resolved)
        #expect(state.scrollTarget?.kind == .scene)
        #expect(state.scrollTarget?.textRange?.location == (text as NSString).range(of: "EXT. STREET - NIGHT").location)
    }

    @Test("Cursor position inside a scene updates selected scene")
    func cursorPositionInsideSceneUpdatesSelectedScene() {
        let text = """
        INT. ROOM - DAY

        Quiet.

        EXT. STREET - NIGHT

        Rain.

        INT. CAR - LATER

        She waits.
        """
        let document = ScreenplayParser.parse(text)
        let cursorLocation = (text as NSString).range(of: "She waits.").location

        let state = EditorUsabilityService.navigationStateForCursor(
            location: cursorLocation,
            text: text,
            scenes: document.scenes,
            parseRevision: 7
        )

        #expect(state.selectedSceneID == "scene-3")
        #expect(state.syncStatus == .resolved)
        #expect(state.cursorTextRange?.location == cursorLocation)
    }

    @Test("Deleted scene selection falls back without crashing")
    func deletedSceneSelectionFallsBackWithoutCrashing() {
        let text = "INT. ROOM - DAY"
        let state = EditorUsabilityService.navigationStateForScene(
            at: 1,
            text: text,
            scenes: ScreenplayParser.parse(text).scenes,
            parseRevision: 2
        )

        #expect(state.selectedSceneID == nil)
        #expect(state.syncStatus == .unresolved)
    }
}
