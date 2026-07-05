import SwiftUI
import DreamJotterCore

enum ScreenplayEditorAdapter: String, CaseIterable, Identifiable {
    case textKit = "TextKit"
    case textEditor = "TextEditor"
    var id: String { rawValue }
}

struct ScriptEditorView: View {
    @Binding var document: ProjectDocumentViewModel
    @State private var editorAdapter: ScreenplayEditorAdapter = .textKit
    @State private var searchText = ""
    @State private var selectedMatchIndex = 0
    @State private var suggestions: [EditorSuggestion] = []
    @State private var selectedSuggestionIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            searchBar
            editorView
                .overlay(alignment: .topLeading) {
                    if document.isEmptyEditorGuidanceVisible {
                        EmptyScriptGuidance(language: document.screenplayLanguage)
                            .padding(20)
                            .allowsHitTesting(false)
                    }
                }
            SuggestionsPanel(
                suggestions: suggestions,
                selectedIndex: selectedSuggestionIndex,
                acceptAction: acceptSuggestion,
                ignoreAction: { _ = dismissSuggestions() }
            )
        }
        .padding()
        .onChange(of: searchText) { _, _ in
            selectedMatchIndex = 0
            navigateToSelectedMatch()
        }
        .onChange(of: document.scriptText) { _, _ in
            selectedMatchIndex = min(selectedMatchIndex, max(matches.count - 1, 0))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(document.project.metadata.title)
                .font(.title2.weight(.semibold))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    editorControls
                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ScreenplayLanguagePicker(document: $document)
                    HStack(spacing: 10) {
                        editorPicker
                        Button("Refresh Parse") { document.refreshParseRespectingLanguage() }
                    }
                }
            }
        }
    }

    private var editorControls: some View {
        HStack(spacing: 10) {
            ScreenplayLanguagePicker(document: $document)
            editorPicker
            Button("Refresh Parse") { document.refreshParseRespectingLanguage() }
        }
    }

    private var editorPicker: some View {
        Picker("Editor", selection: $editorAdapter) {
            ForEach(ScreenplayEditorAdapter.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .frame(width: 160)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary).accessibilityHidden(true)
            TextField("Find in script", text: $searchText).textFieldStyle(.roundedBorder)
            Text(matchSummary).font(.caption.monospacedDigit()).foregroundStyle(.secondary).frame(minWidth: 72, alignment: .trailing)
            Button(action: selectPreviousMatch) { Image(systemName: "chevron.up") }
                .disabled(matches.isEmpty).help("Previous match").accessibilityLabel("Previous match")
            Button(action: selectNextMatch) { Image(systemName: "chevron.down") }
                .disabled(matches.isEmpty).help("Next match").accessibilityLabel("Next match")
            if !searchText.isEmpty {
                Button("Clear") { searchText = ""; selectedMatchIndex = 0 }
            }
        }
    }

    @ViewBuilder
    private var editorView: some View {
        switch editorAdapter {
        case .textKit:
            TextKitScreenplayEditorView(
                text: Binding(
                    get: { document.scriptText },
                    set: { document.updateScriptTextRespectingLanguage($0) }
                ),
                navigationState: document.editorNavigationState,
                styleRuns: ScreenplayParagraphTypeControl.styleRuns(in: document.scriptText),
                onSmartEnter: { location in
                    document.performSmartEnterRespectingLanguage(at: location)
                    refreshSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
                },
                onTabCycle: { location in
                    document.performTabCycleRespectingLanguage(at: location)
                    refreshSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
                },
                onTextChanged: refreshSuggestions,
                onSelectionChanged: { location in
                    document.updateSelectedSceneForCursor(location: location)
                    refreshSuggestions(cursorLocation: location)
                },
                onSuggestionMove: moveSuggestionSelection,
                onSuggestionAccept: acceptSelectedSuggestion,
                onSuggestionDismiss: dismissSuggestions,
                onNavigationApplied: { document.clearEditorNavigationRequest() }
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
        case .textEditor:
            TextEditor(text: Binding(
                get: { document.scriptText },
                set: {
                    document.updateScriptTextRespectingLanguage($0)
                    refreshSuggestions(cursorLocation: (document.scriptText as NSString).length)
                }
            ))
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(10)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private func refreshSuggestions(cursorLocation: Int) {
        let currentLine = EditorUsabilityService.currentLine(in: document.scriptText, cursorLocation: cursorLocation)
        let lineStart = currentLine.range.location
        let lineLength = (currentLine.text as NSString).length
        let safeCursor = min(max(cursorLocation, lineStart), lineStart + lineLength)
        let prefixLength = safeCursor - lineStart
        let prefix = (currentLine.text as NSString).substring(with: NSRange(location: 0, length: prefixLength))

        if isSceneHeadingDraft(prefix) {
            suggestions = SceneHeadingAutocompleteEngine.suggestions(
                line: currentLine.text,
                lineStart: lineStart,
                cursorLocation: safeCursor,
                scenes: document.scenes,
                language: document.screenplayLanguage
            )
        } else {
            let context = CharacterCueEngine.suggestionContext(
                in: currentLine.text,
                lineStart: lineStart,
                cursorLocation: safeCursor
            )
            suggestions = CharacterCueEngine.suggestions(
                context: context,
                characters: document.characters.map(\.displayName)
            )
        }
        selectedSuggestionIndex = suggestions.isEmpty
            ? 0
            : min(selectedSuggestionIndex, suggestions.count - 1)
    }

    private func isSceneHeadingDraft(_ text: String) -> Bool {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !value.isEmpty else { return false }
        let prefixes = ["INT.", "EXT.", "INT./EXT.", "EXT./INT.", "I/E."]
        return prefixes.contains { $0.hasPrefix(value) || value.hasPrefix($0) }
    }

    private func moveSuggestionSelection(by offset: Int) -> Bool {
        guard !suggestions.isEmpty else { return false }
        selectedSuggestionIndex = (selectedSuggestionIndex + offset + suggestions.count) % suggestions.count
        return true
    }

    private func acceptSelectedSuggestion() -> Bool {
        guard suggestions.indices.contains(selectedSuggestionIndex) else { return false }
        acceptSuggestion(suggestions[selectedSuggestionIndex])
        return true
    }

    private func acceptSuggestion(_ suggestion: EditorSuggestion) {
        document.acceptEditorSuggestionRespectingLanguage(suggestion)
        document.requestNavigation(toTextRange: EditorTextRange(
            location: suggestion.textRange.location + (suggestion.replacementText as NSString).length,
            length: 0
        ))
        suggestions = []
        selectedSuggestionIndex = 0
    }

    private func dismissSuggestions() -> Bool {
        guard !suggestions.isEmpty else { return false }
        suggestions = []
        selectedSuggestionIndex = 0
        document.ignoreEditorSuggestions()
        return true
    }

    private var matches: [EditorTextRange] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        let source = document.scriptText as NSString
        var results: [EditorTextRange] = []
        var searchRange = NSRange(location: 0, length: source.length)
        while searchRange.length > 0 {
            let range = source.range(of: query, options: [.caseInsensitive, .diacriticInsensitive], range: searchRange)
            guard range.location != NSNotFound else { break }
            results.append(EditorTextRange(location: range.location, length: range.length))
            let next = range.location + max(range.length, 1)
            guard next <= source.length else { break }
            searchRange = NSRange(location: next, length: source.length - next)
        }
        return results
    }

    private var matchSummary: String {
        guard !searchText.isEmpty else { return "" }
        guard !matches.isEmpty else { return String(localized: "No matches") }
        return String(format: String(localized: "%lld of %lld"), selectedMatchIndex + 1, matches.count)
    }

    private func selectNextMatch() {
        guard !matches.isEmpty else { return }
        selectedMatchIndex = (selectedMatchIndex + 1) % matches.count
        navigateToSelectedMatch()
    }

    private func selectPreviousMatch() {
        guard !matches.isEmpty else { return }
        selectedMatchIndex = (selectedMatchIndex - 1 + matches.count) % matches.count
        navigateToSelectedMatch()
    }

    private func navigateToSelectedMatch() {
        guard !matches.isEmpty else { return }
        selectedMatchIndex = min(max(selectedMatchIndex, 0), matches.count - 1)
        editorAdapter = .textKit
        document.requestNavigation(toTextRange: matches[selectedMatchIndex])
    }
}

private struct SuggestionsPanel: View {
    let suggestions: [EditorSuggestion]
    let selectedIndex: Int
    let acceptAction: (EditorSuggestion) -> Void
    let ignoreAction: () -> Void

    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Suggestions").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text("↑↓ select • Return or Tab accept • Esc dismiss").font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                    Button("Ignore", action: ignoreAction).buttonStyle(.borderless)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, suggestion in
                            Button { acceptAction(suggestion) } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.displayText).font(.callout.monospaced())
                                    Text(localizedType(suggestion.type.rawValue)).font(.caption2).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4).padding(.horizontal, 8)
                                .background(index == selectedIndex ? Color.accentColor.opacity(0.16) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .accessibilityLabel(String(format: String(localized: "Accept suggestion: %@"), suggestion.displayText))
                            .accessibilityValue(index == selectedIndex ? String(localized: "Selected") : "")
                        }
                    }
                }
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private func localizedType(_ rawValue: String) -> String {
        switch rawValue {
        case "sceneHeading": String(localized: "Scene Heading")
        case "character": String(localized: "Character")
        case "location": String(localized: "Location")
        case "timeOfDay": String(localized: "Time of Day")
        default: String(localized: String.LocalizationValue(rawValue))
        }
    }
}

private struct EmptyScriptGuidance: View {
    let language: ScreenplayLanguageProfile
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Start with a scene heading").font(.callout.weight(.semibold))
            Text(language == .spanishLatinAmerica ? "INT. DEPARTAMENTO - MAÑANA" : "INT. APARTMENT - MORNING").font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "Una habitación tranquila antes del amanecer." : "A quiet room before sunrise.").font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "SOFÍA" : "ELENA").font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "Aquí comenzamos." : "We begin here.").font(.callout.monospaced())
        }.foregroundStyle(.secondary)
    }
}

private struct ScreenplayLanguagePicker: View {
    @Binding var document: ProjectDocumentViewModel
    var body: some View {
        Picker("Screenplay Language", selection: Binding(
            get: { document.screenplayLanguage },
            set: { document.setScreenplayLanguage($0) }
        )) {
            Text("Automatic").tag(ScreenplayLanguageProfile.automatic)
            Text("English").tag(ScreenplayLanguageProfile.english)
            Text("Spanish (Latin America)").tag(ScreenplayLanguageProfile.spanishLatinAmerica)
        }
        .frame(width: 210)
    }
}

extension ProjectDocumentViewModel {
    var screenplayLanguage: ScreenplayLanguageProfile { ScreenplayLanguagePersistence.language(in: project) }

    mutating func setScreenplayLanguage(_ language: ScreenplayLanguageProfile) {
        guard language != screenplayLanguage else { return }
        let configured = ScreenplayLanguagePersistence.setting(language, in: project)
        let parsed = ScreenplayParser.parse(scriptText, language: language)
        let updated = DreamJotterProject(
            metadata: configured.metadata, screenplay: parsed, mode: configured.mode,
            template: configured.template, characters: configured.characters,
            ignoredDetectedCharacterKeys: configured.ignoredDetectedCharacterKeys,
            locations: configured.locations, ignoredDetectedLocationKeys: configured.ignoredDetectedLocationKeys,
            notes: configured.notes, inboxItems: configured.inboxItems, sceneCards: configured.sceneCards,
            snapshots: configured.snapshots, exportPresets: configured.exportPresets,
            story: configured.story, pro: configured.pro
        )
        self = ScreenplayParsingContext.$language.withValue(language) {
            ProjectDocumentViewModel(project: updated, packageURL: packageURL, scriptText: scriptText, isDirty: true)
        }
    }

    mutating func updateScriptTextRespectingLanguage(_ text: String) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) { updateScriptText(text) }
    }

    mutating func refreshParseRespectingLanguage(now: Date = Date()) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) { refreshParse(now: now) }
    }

    mutating func acceptEditorSuggestionRespectingLanguage(_ suggestion: EditorSuggestion) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) { acceptEditorSuggestion(suggestion) }
    }

    mutating func performSmartEnterRespectingLanguage(at cursorLocation: Int) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) { performSmartEnter(at: cursorLocation) }
    }

    mutating func performTabCycleRespectingLanguage(at cursorLocation: Int) {
        ScreenplayParsingContext.$language.withValue(screenplayLanguage) { performTabCycle(at: cursorLocation) }
    }

    mutating func saveRespectingLanguage(to packageURL: URL, now: Date = Date()) throws {
        try ScreenplayParsingContext.$language.withValue(screenplayLanguage) { try save(to: packageURL, now: now) }
    }
}
