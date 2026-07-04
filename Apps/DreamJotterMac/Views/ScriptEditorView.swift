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
                suggestions: document.editorSuggestions,
                acceptAction: { suggestion in
                    document.acceptEditorSuggestionRespectingLanguage(suggestion)
                },
                ignoreAction: {
                    document.ignoreEditorSuggestions()
                }
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
        HStack {
            Text(document.project.metadata.title)
                .font(.title2.weight(.semibold))

            Spacer()

            ScreenplayLanguagePicker(document: $document)

            Picker("Editor", selection: $editorAdapter) {
                ForEach(ScreenplayEditorAdapter.allCases) { adapter in
                    Text(adapter.rawValue).tag(adapter)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 180)

            Button("Refresh Parse") {
                document.refreshParseRespectingLanguage()
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Find in script", text: $searchText)
                .textFieldStyle(.roundedBorder)
            Text(matchSummary)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 72, alignment: .trailing)
            Button {
                selectPreviousMatch()
            } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(matches.isEmpty)
            .help("Previous match")
            .accessibilityLabel("Previous match")
            Button {
                selectNextMatch()
            } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(matches.isEmpty)
            .help("Next match")
            .accessibilityLabel("Next match")
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                    selectedMatchIndex = 0
                }
            }
        }
    }

    @ViewBuilder
    private var editorView: some View {
        switch editorAdapter {
        case .textKit:
            TextKitScreenplayEditorView(text: Binding(
                get: { document.scriptText },
                set: { document.updateScriptTextRespectingLanguage($0) }
            ), navigationState: document.editorNavigationState,
            styleRuns: ScreenplayParagraphTypeControl.styleRuns(in: document.scriptText),
            onSmartEnter: { location in
                document.performSmartEnterRespectingLanguage(at: location)
                document.refreshEditorSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
            },
            onTabCycle: { location in
                document.performTabCycleRespectingLanguage(at: location)
                document.refreshEditorSuggestions(cursorLocation: document.editorNavigationState.cursorTextRange?.location ?? location)
            },
            onTextChanged: { location in
                document.refreshEditorSuggestions(cursorLocation: location)
            },
            onSelectionChanged: { location in
                document.updateSelectedSceneForCursor(location: location)
                document.refreshEditorSuggestions(cursorLocation: location)
            },
            onNavigationApplied: {
                document.clearEditorNavigationRequest()
            })
            .clipShape(RoundedRectangle(cornerRadius: 6))
        case .textEditor:
            TextEditor(text: Binding(
                get: { document.scriptText },
                set: {
                    document.updateScriptTextRespectingLanguage($0)
                    document.refreshEditorSuggestions(cursorLocation: (document.scriptText as NSString).length)
                }
            ))
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(10)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private var matches: [EditorTextRange] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        let source = document.scriptText as NSString
        var results: [EditorTextRange] = []
        var searchRange = NSRange(location: 0, length: source.length)
        let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]

        while searchRange.length > 0 {
            let range = source.range(of: query, options: options, range: searchRange)
            guard range.location != NSNotFound else { break }
            results.append(EditorTextRange(location: range.location, length: range.length))
            let nextLocation = range.location + max(range.length, 1)
            guard nextLocation <= source.length else { break }
            searchRange = NSRange(location: nextLocation, length: source.length - nextLocation)
        }
        return results
    }

    private var matchSummary: String {
        guard !searchText.isEmpty else { return "" }
        guard !matches.isEmpty else { return String(localized: "No matches") }
        return String(
            format: String(localized: "%lld of %lld"),
            selectedMatchIndex + 1,
            matches.count
        )
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
    let acceptAction: (EditorSuggestion) -> Void
    let ignoreAction: () -> Void

    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Suggestions")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Ignore") { ignoreAction() }
                        .buttonStyle(.borderless)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(suggestions, id: \.id) { suggestion in
                            Button { acceptAction(suggestion) } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.displayText)
                                        .font(.callout.monospaced())
                                    Text(localizedType(suggestion.type.rawValue))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                            }
                            .accessibilityLabel(String(format: String(localized: "Accept suggestion: %@"), suggestion.displayText))
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
        case "transition": String(localized: "Transition")
        case "shot": String(localized: "Shot")
        case "parenthetical": String(localized: "Parenthetical")
        default: String(localized: String.LocalizationValue(rawValue))
        }
    }
}

private struct EmptyScriptGuidance: View {
    let language: ScreenplayLanguageProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Start with a scene heading")
                .font(.callout.weight(.semibold))
            Text(language == .spanishLatinAmerica ? "INT. DEPARTAMENTO - MAÑANA" : "INT. APARTMENT - MORNING")
                .font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "Una habitación tranquila antes del amanecer." : "A quiet room before sunrise.")
                .font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "SOFÍA" : "ELENA")
                .font(.callout.monospaced())
            Text(language == .spanishLatinAmerica ? "Aquí comenzamos." : "We begin here.")
                .font(.callout.monospaced())
        }
        .foregroundStyle(.secondary)
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
        .frame(width: 240)
    }
}

extension ProjectDocumentViewModel {
    var screenplayLanguage: ScreenplayLanguageProfile {
        ScreenplayLanguagePersistence.language(in: project)
    }

    mutating func setScreenplayLanguage(_ language: ScreenplayLanguageProfile) {
        guard language != screenplayLanguage else { return }
        let projectWithSetting = ScreenplayLanguagePersistence.setting(language, in: project)
        let parsed = ScreenplayParser.parse(scriptText, language: language)
        let updated = DreamJotterProject(
            metadata: projectWithSetting.metadata,
            screenplay: parsed,
            mode: projectWithSetting.mode,
            template: projectWithSetting.template,
            characters: projectWithSetting.characters,
            ignoredDetectedCharacterKeys: projectWithSetting.ignoredDetectedCharacterKeys,
            locations: projectWithSetting.locations,
            ignoredDetectedLocationKeys: projectWithSetting.ignoredDetectedLocationKeys,
            notes: projectWithSetting.notes,
            inboxItems: projectWithSetting.inboxItems,
            sceneCards: projectWithSetting.sceneCards,
            snapshots: projectWithSetting.snapshots,
            exportPresets: projectWithSetting.exportPresets,
            story: projectWithSetting.story,
            pro: projectWithSetting.pro
        )
        self = ScreenplayParsingContext.$language.withValue(language) {
            ProjectDocumentViewModel(
                project: updated,
                packageURL: packageURL,
                scriptText: scriptText,
                isDirty: true
            )
        }
    }

    mutating func updateScriptTextRespectingLanguage(_ text: String) {
        let language = screenplayLanguage
        ScreenplayParsingContext.$language.withValue(language) {
            updateScriptText(text)
        }
    }

    mutating func refreshParseRespectingLanguage(now: Date = Date()) {
        let language = screenplayLanguage
        ScreenplayParsingContext.$language.withValue(language) {
            refreshParse(now: now)
        }
    }

    mutating func acceptEditorSuggestionRespectingLanguage(_ suggestion: EditorSuggestion) {
        let language = screenplayLanguage
        ScreenplayParsingContext.$language.withValue(language) {
            acceptEditorSuggestion(suggestion)
        }
    }

    mutating func performSmartEnterRespectingLanguage(at cursorLocation: Int) {
        let language = screenplayLanguage
        ScreenplayParsingContext.$language.withValue(language) {
            performSmartEnter(at: cursorLocation)
        }
    }

    mutating func performTabCycleRespectingLanguage(at cursorLocation: Int) {
        let language = screenplayLanguage
        ScreenplayParsingContext.$language.withValue(language) {
            performTabCycle(at: cursorLocation)
        }
    }

    mutating func saveRespectingLanguage(to packageURL: URL, now: Date = Date()) throws {
        let language = screenplayLanguage
        try ScreenplayParsingContext.$language.withValue(language) {
            try save(to: packageURL, now: now)
        }
    }
}
