import DreamJotterCore
import Foundation

struct ProjectDashboardSnapshot: Equatable {
    let title: String
    let logline: String?
    let synopsis: String?
    let sceneCount: Int
    let characterCount: Int
    let unresolvedCharacterCount: Int
    let locationCount: Int
    let unresolvedLocationCount: Int
    let noteCount: Int
    let todoCount: Int
}

enum NoteLinkTarget: Equatable {
    case project
    case scene(DreamJotterCore.Scene)
    case character(CharacterRecord)
    case location(LocationRecord)
}

struct ProjectDocumentViewModel: Equatable {
    private(set) var project: DreamJotterProject
    var scriptText: String {
        didSet {
            if scriptText != oldValue {
                editorParseState = EditorUsabilityService.parseStateAfterTextChange(editorParseState)
                isDirty = true
                reparseScript()
            }
        }
    }
    private(set) var packageURL: URL?
    private(set) var isDirty: Bool
    private(set) var editorParseState = EditorParseState()
    private(set) var editorNavigationState = EditorNavigationState()
    private(set) var editorSuggestions: [EditorSuggestion] = []

    init(project: DreamJotterProject, packageURL: URL? = nil, scriptText: String? = nil, isDirty: Bool = false) {
        self.project = project
        self.packageURL = packageURL
        self.scriptText = scriptText ?? FountainIO.exportScreenplay(project.screenplay)
        self.isDirty = isDirty
        reparseScript()
    }

    var dashboard: ProjectDashboardSnapshot {
        ProjectDashboardSnapshot(
            title: project.metadata.title,
            logline: project.story.logline?.text.nilIfBlank,
            synopsis: project.story.synopsis?.text.nilIfBlank,
            sceneCount: project.screenplay.scenes.count,
            characterCount: characters.count,
            unresolvedCharacterCount: CharacterManager.unresolvedDetectedCharacters(for: project).count,
            locationCount: locations.count,
            unresolvedLocationCount: LocationManager.unresolvedDetectedLocations(for: project).count,
            noteCount: NotesIndex.openNotes(in: project).count,
            todoCount: scriptTodoNotes.count
        )
    }

    var workspaceSummary: ProjectWorkspaceSummary {
        ProjectWorkspaceSummaryBuilder.summary(
            for: project,
            isDirty: isDirty,
            lastSavedAt: packageURL == nil ? nil : project.metadata.modifiedAt
        )
    }

    var scenes: [Scene] {
        project.screenplay.scenes
    }

    var characters: [CharacterRecord] {
        CharacterManager.records(for: project, now: project.metadata.modifiedAt)
    }

    var detectedCharacters: [DetectedCharacter] {
        CharacterManager.detectedCharacters(for: project)
    }

    var unresolvedDetectedCharacters: [DetectedCharacter] {
        CharacterManager.unresolvedDetectedCharacters(for: project)
    }

    var locations: [LocationRecord] {
        LocationManager.records(for: project, now: project.metadata.modifiedAt)
    }

    var detectedLocations: [DetectedLocation] {
        LocationManager.detectedLocations(for: project)
    }

    var unresolvedDetectedLocations: [DetectedLocation] {
        LocationManager.unresolvedDetectedLocations(for: project)
    }

    var sceneCards: [SceneCard] {
        SceneCardBuilder.cards(for: project)
    }

    var notes: [ProjectNote] {
        project.notes
    }

    var openNotes: [ProjectNote] {
        NotesIndex.openNotes(in: project)
    }

    var scriptTodoNotes: [ProjectNote] {
        NotesIndex.detectedScriptTodos(in: project, now: project.metadata.modifiedAt)
    }

    var loglineText: String {
        project.story.logline?.text ?? ""
    }

    var synopsisText: String {
        project.story.synopsis?.text ?? ""
    }

    var healthFindings: [HealthFinding] {
        HealthReport.findings(for: project)
    }

    var fountainExportText: String {
        FountainIO.exportScreenplay(project.screenplay)
    }

    mutating func save(to packageURL: URL, now: Date = Date()) throws {
        reparseScript(modifiedAt: now)
        try DreamJotterPackageStore.save(project, to: packageURL, updatedAt: now)
        self.packageURL = packageURL
        isDirty = false
    }

    func exportFountain(to fileURL: URL) throws {
        try fountainExportText.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    mutating func updateScriptText(_ text: String) {
        scriptText = text
    }

    mutating func refreshParse(now: Date = Date()) {
        reparseScript(parseDate: now)
    }

    func smartEnterNextKind(from currentKind: ScriptElementKind?) -> ScriptElementKind {
        EditorUsabilityService.nextKindAfterEnter(from: currentKind, mode: project.mode)
    }

    func tabCycleNextKind(from currentKind: ScriptElementKind) -> ScriptElementKind {
        EditorUsabilityService.cycleKindAfterTab(from: currentKind)
    }

    func characterSuggestions(prefix: String, replacementRange: EditorTextRange) -> [EditorSuggestion] {
        EditorUsabilityService.characterSuggestions(
            prefix: prefix,
            characters: characters.map(\.displayName),
            replacementRange: replacementRange
        )
    }

    func sceneHeadingSuggestions(prefix: String, replacementRange: EditorTextRange) -> [EditorSuggestion] {
        EditorUsabilityService.sceneHeadingSuggestions(
            prefix: prefix,
            scenes: scenes,
            replacementRange: replacementRange
        )
    }

    var isEmptyEditorGuidanceVisible: Bool {
        scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var editorStyleRuns: [EditorLineStyleRun] {
        EditorUsabilityService.styleRuns(in: scriptText)
    }

    mutating func refreshEditorSuggestions(cursorLocation: Int) {
        editorSuggestions = suggestions(at: cursorLocation)
    }

    mutating func acceptEditorSuggestion(_ suggestion: EditorSuggestion) {
        scriptText = EditorUsabilityService.replacing(
            range: suggestion.textRange,
            in: scriptText,
            with: suggestion.replacementText
        )
        editorSuggestions = []
    }

    mutating func ignoreEditorSuggestions() {
        editorSuggestions = []
    }

    mutating func performSmartEnter(at cursorLocation: Int) {
        let currentKind = currentLineKind(at: cursorLocation)
        let insertion = EditorUsabilityService.smartEnterInsertion(after: currentKind, mode: project.mode)
        let targetLocation = cursorLocation + (insertion as NSString).length
        scriptText = EditorUsabilityService.replacing(
            range: EditorTextRange(location: cursorLocation, length: 0),
            in: scriptText,
            with: insertion
        )
        requestEditorCursorNavigation(to: targetLocation)
    }

    mutating func performTabCycle(at cursorLocation: Int) {
        let currentLine = EditorUsabilityService.currentLine(in: scriptText, cursorLocation: cursorLocation)
        let contentRange = EditorTextRange(
            location: currentLine.range.location,
            length: (currentLine.text as NSString).length
        )
        let currentKind = EditorUsabilityService.lineKind(for: currentLine.text)
        let cycled = EditorUsabilityService.tabCycledLineText(currentLine.text, currentKind: currentKind)
        scriptText = EditorUsabilityService.replacing(range: contentRange, in: scriptText, with: cycled.text)
        requestEditorCursorNavigation(to: contentRange.location + (cycled.text as NSString).length)
    }

    mutating func requestNavigation(toSceneAt index: Int) {
        editorNavigationState = EditorUsabilityService.navigationStateForScene(
            at: index,
            text: scriptText,
            scenes: scenes,
            parseRevision: editorParseState.currentTextRevision
        )
    }

    mutating func clearEditorNavigationRequest() {
        editorNavigationState = EditorNavigationState(
            selectedSceneID: editorNavigationState.selectedSceneID,
            selectedScriptElementID: editorNavigationState.selectedScriptElementID,
            cursorTextRange: editorNavigationState.cursorTextRange,
            lastKnownParseRevision: editorNavigationState.lastKnownParseRevision,
            syncStatus: editorNavigationState.syncStatus
        )
    }

    mutating func updateSelectedSceneForCursor(location: Int) {
        editorNavigationState = EditorUsabilityService.navigationStateForCursor(
            location: location,
            text: scriptText,
            scenes: scenes,
            parseRevision: editorParseState.currentTextRevision
        )
    }

    mutating func updateTitle(_ title: String, now: Date = Date()) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedTitle = trimmed.isEmpty ? "Untitled" : trimmed
        guard normalizedTitle != project.metadata.title else { return }
        let metadata = ProjectMetadata(
            id: project.metadata.id,
            title: normalizedTitle,
            createdAt: project.metadata.createdAt,
            modifiedAt: now,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )
        replaceProject(metadata: metadata)
        isDirty = true
    }

    mutating func updateLogline(_ text: String, now: Date = Date()) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != loglineText else { return }
        let story = StoryDevelopmentState(
            setup: project.story.setup,
            logline: trimmed.isEmpty ? nil : LoglineRecord(
                id: project.story.logline?.id ?? "logline",
                text: trimmed,
                createdAt: project.story.logline?.createdAt ?? now,
                updatedAt: now
            ),
            synopsis: project.story.synopsis,
            beatSheets: project.story.beatSheets,
            suggestions: project.story.suggestions
        )
        replaceProject(story: story, modifiedAt: now)
        isDirty = true
    }

    mutating func updateSynopsis(_ text: String, now: Date = Date()) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != synopsisText else { return }
        let story = StoryDevelopmentState(
            setup: project.story.setup,
            logline: project.story.logline,
            synopsis: trimmed.isEmpty ? nil : SynopsisRecord(
                id: project.story.synopsis?.id ?? "synopsis",
                text: trimmed,
                createdAt: project.story.synopsis?.createdAt ?? now,
                updatedAt: now
            ),
            beatSheets: project.story.beatSheets,
            suggestions: project.story.suggestions
        )
        replaceProject(story: story, modifiedAt: now)
        isDirty = true
    }

    mutating func addNote(title: String, body: String, target: NoteLinkTarget, now: Date = Date()) {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBody.isEmpty else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = ProjectNote(
            id: "note-\(UUID().uuidString)",
            title: trimmedTitle.isEmpty ? nil : trimmedTitle,
            body: trimmedBody,
            links: [noteLink(for: target)],
            createdAt: now,
            updatedAt: now
        )
        replaceProject(notes: project.notes + [note], modifiedAt: now)
        isDirty = true
    }

    mutating func createCharacterProfile(name: String, note: String = "", now: Date = Date()) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let normalizedKey = TextNormalization.key(for: trimmedName)
        guard !project.characters.contains(where: { $0.normalizedKey == normalizedKey }) else { return }

        let profile = CharacterRecord(
            id: "character-\(normalizedKey.lowercased().replacingOccurrences(of: " ", with: "-"))",
            displayName: trimmedName,
            normalizedKey: normalizedKey,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            source: .manual,
            createdAt: now,
            updatedAt: now
        )
        replaceProject(characters: project.characters + [profile], modifiedAt: now)
        isDirty = true
    }

    mutating func updateCharacterProfile(_ profile: CharacterRecord, name: String, note: String, now: Date = Date()) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let normalizedKey = TextNormalization.key(for: trimmedName)
        guard !project.characters.contains(where: { $0.id != profile.id && $0.normalizedKey == normalizedKey }) else { return }

        let updated = CharacterRecord(
            id: profile.id,
            displayName: trimmedName,
            normalizedKey: normalizedKey,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            source: profile.source == .detected ? .manual : profile.source,
            createdAt: profile.createdAt,
            updatedAt: now
        )
        let profiles = project.characters.map { $0.id == profile.id ? updated : $0 }
        guard profiles != project.characters else { return }
        replaceProject(characters: profiles, modifiedAt: now)
        isDirty = true
    }

    mutating func createLocationProfile(name: String, note: String = "", now: Date = Date()) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let normalizedKey = TextNormalization.key(for: trimmedName)
        guard !project.locations.contains(where: { $0.normalizedKey == normalizedKey }) else { return }

        let profile = LocationRecord(
            id: "location-\(normalizedKey.lowercased().replacingOccurrences(of: " ", with: "-"))",
            displayName: trimmedName,
            normalizedKey: normalizedKey,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            source: .manual,
            createdAt: now,
            updatedAt: now
        )
        replaceProject(locations: project.locations + [profile], modifiedAt: now)
        isDirty = true
    }

    mutating func updateLocationProfile(_ profile: LocationRecord, name: String, note: String, now: Date = Date()) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let normalizedKey = TextNormalization.key(for: trimmedName)
        guard !project.locations.contains(where: { $0.id != profile.id && $0.normalizedKey == normalizedKey }) else { return }

        let updated = LocationRecord(
            id: profile.id,
            displayName: trimmedName,
            normalizedKey: normalizedKey,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            source: profile.source == .detected ? .manual : profile.source,
            createdAt: profile.createdAt,
            updatedAt: now
        )
        let profiles = project.locations.map { $0.id == profile.id ? updated : $0 }
        guard profiles != project.locations else { return }
        replaceProject(locations: profiles, modifiedAt: now)
        isDirty = true
    }

    mutating func convertDetectedCharacterToProfile(_ detection: DetectedCharacter, now: Date = Date()) {
        let updated = CharacterManager.convertDetectedCharacter(
            named: detection.name,
            in: project,
            now: now
        )
        guard updated != project else { return }
        project = updated
        isDirty = true
    }

    mutating func ignoreDetectedCharacter(_ detection: DetectedCharacter, now: Date = Date()) {
        let updated = CharacterManager.ignoreDetectedCharacter(
            named: detection.name,
            in: project,
            now: now
        )
        guard updated != project else { return }
        project = updated
        isDirty = true
    }

    mutating func convertDetectedLocationToProfile(_ detection: DetectedLocation, now: Date = Date()) {
        let updated = LocationManager.convertDetectedLocation(
            named: detection.name,
            in: project,
            now: now
        )
        guard updated != project else { return }
        project = updated
        isDirty = true
    }

    mutating func ignoreDetectedLocation(_ detection: DetectedLocation, now: Date = Date()) {
        let updated = LocationManager.ignoreDetectedLocation(
            named: detection.name,
            in: project,
            now: now
        )
        guard updated != project else { return }
        project = updated
        isDirty = true
    }

    mutating func updateSceneStatus(sceneHeading: String, status: SceneCardStatus, now: Date = Date()) {
        let updated = SceneCardBuilder.updateStatus(status, forSceneHeading: sceneHeading, in: project, now: now)
        guard updated != project else { return }
        project = updated
        isDirty = true
    }

    mutating func resolveNote(_ note: ProjectNote, now: Date = Date()) {
        let updated = NotesIndex.resolve(noteID: note.id, in: project, now: now)
        guard updated != project else { return }
        project = updated
        isDirty = true
    }

    private mutating func reparseScript(modifiedAt: Date? = nil, parseDate: Date? = nil) {
        let parsed = ScreenplayParser.parse(scriptText)
        let updatedMetadata = metadata(modifiedAt: modifiedAt)
        project = DreamJotterProject(
            metadata: updatedMetadata,
            screenplay: parsed,
            mode: project.mode,
            template: project.template,
            characters: project.characters,
            ignoredDetectedCharacterKeys: project.ignoredDetectedCharacterKeys,
            locations: project.locations,
            ignoredDetectedLocationKeys: project.ignoredDetectedLocationKeys,
            notes: project.notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: project.story,
            pro: project.pro
        )
        editorParseState = EditorUsabilityService.refreshedParseState(
            textRevision: editorParseState.currentTextRevision,
            document: parsed,
            date: parseDate ?? modifiedAt ?? editorParseState.lastParseDate ?? project.metadata.modifiedAt
        )
    }

    private func noteLink(for target: NoteLinkTarget) -> NoteLink {
        switch target {
        case .project:
            return NoteLink(targetKind: .project, targetID: project.metadata.id)
        case .scene(let scene):
            return NoteLink(targetKind: .scene, targetID: scene.heading)
        case .character(let character):
            return NoteLink(targetKind: .character, targetID: character.id)
        case .location(let location):
            return NoteLink(targetKind: .location, targetID: location.id)
        }
    }

    private func metadata(modifiedAt: Date?) -> ProjectMetadata {
        guard let modifiedAt else { return project.metadata }
        return ProjectMetadata(
            id: project.metadata.id,
            title: project.metadata.title,
            createdAt: project.metadata.createdAt,
            modifiedAt: modifiedAt,
            schemaVersion: project.metadata.schemaVersion,
            primaryScreenplayID: project.metadata.primaryScreenplayID,
            packageExtension: project.metadata.packageExtension
        )
    }

    private mutating func replaceProject(
        metadata: ProjectMetadata? = nil,
        characters: [CharacterRecord]? = nil,
        ignoredDetectedCharacterKeys: [String]? = nil,
        locations: [LocationRecord]? = nil,
        ignoredDetectedLocationKeys: [String]? = nil,
        notes: [ProjectNote]? = nil,
        story: StoryDevelopmentState? = nil,
        modifiedAt: Date? = nil
    ) {
        project = DreamJotterProject(
            metadata: metadata ?? self.metadata(modifiedAt: modifiedAt),
            screenplay: project.screenplay,
            mode: project.mode,
            template: project.template,
            characters: characters ?? project.characters,
            ignoredDetectedCharacterKeys: ignoredDetectedCharacterKeys ?? project.ignoredDetectedCharacterKeys,
            locations: locations ?? project.locations,
            ignoredDetectedLocationKeys: ignoredDetectedLocationKeys ?? project.ignoredDetectedLocationKeys,
            notes: notes ?? project.notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: project.snapshots,
            exportPresets: project.exportPresets,
            story: story ?? project.story,
            pro: project.pro
        )
    }

    private func currentLineKind(at cursorLocation: Int) -> ScriptElementKind {
        let currentLine = EditorUsabilityService.currentLine(in: scriptText, cursorLocation: cursorLocation)
        return EditorUsabilityService.lineKind(for: currentLine.text)
    }

    private mutating func requestEditorCursorNavigation(to location: Int) {
        let clampedLocation = min(max(0, location), (scriptText as NSString).length)
        let range = EditorTextRange(location: clampedLocation, length: 0)
        editorNavigationState = EditorNavigationState(
            selectedSceneID: editorNavigationState.selectedSceneID,
            selectedScriptElementID: editorNavigationState.selectedScriptElementID,
            cursorTextRange: range,
            scrollTarget: EditorScrollTarget(kind: .textRange, textRange: range),
            lastKnownParseRevision: editorParseState.currentTextRevision,
            syncStatus: .resolved
        )
    }

    private func suggestions(at cursorLocation: Int) -> [EditorSuggestion] {
        let currentLine = EditorUsabilityService.currentLine(in: scriptText, cursorLocation: cursorLocation)
        let lineStart = currentLine.range.location
        let lineTextLength = (currentLine.text as NSString).length
        let safeCursor = min(max(cursorLocation, lineStart), lineStart + lineTextLength)
        let prefixLength = safeCursor - lineStart
        let prefix = (currentLine.text as NSString).substring(with: NSRange(location: 0, length: prefixLength))
        let trimmedPrefix = prefix.trimmingCharacters(in: .whitespacesAndNewlines)

        if isSceneHeadingDraft(trimmedPrefix) {
            return sceneHeadingDraftSuggestions(prefix: prefix, lineStart: lineStart, cursorLocation: safeCursor)
        }

        return characterSuggestions(
            prefix: prefix,
            replacementRange: EditorTextRange(location: lineStart, length: prefixLength)
        )
    }

    private func sceneHeadingDraftSuggestions(prefix: String, lineStart: Int, cursorLocation: Int) -> [EditorSuggestion] {
        let nsPrefix = prefix as NSString
        let fullPrefixRange = EditorTextRange(location: lineStart, length: nsPrefix.length)
        var suggestions: [EditorSuggestion] = []

        suggestions.append(contentsOf: EditorUsabilityService.sceneHeadingSuggestions(
            prefix: prefix,
            scenes: [],
            replacementRange: fullPrefixRange
        ))

        if let locationRange = sceneHeadingLocationRange(in: prefix, lineStart: lineStart, cursorLocation: cursorLocation) {
            suggestions.append(contentsOf: EditorUsabilityService.locationSuggestions(
                prefix: prefix,
                scenes: scenes,
                replacementRange: locationRange
            ))
        }

        if let timeRange = sceneHeadingTimeRange(in: prefix, lineStart: lineStart) {
            suggestions.append(contentsOf: EditorUsabilityService.timeOfDaySuggestions(
                prefix: (prefix as NSString).substring(from: timeRange.location - lineStart),
                replacementRange: timeRange
            ))
        }

        return suggestions
    }

    private func isSceneHeadingDraft(_ text: String) -> Bool {
        let uppercased = text.uppercased()
        return uppercased.hasPrefix("INT.")
            || uppercased.hasPrefix("EXT.")
            || uppercased.hasPrefix("INT./EXT.")
            || uppercased.hasPrefix("EXT./INT.")
    }

    private func sceneHeadingLocationRange(in prefix: String, lineStart: Int, cursorLocation: Int) -> EditorTextRange? {
        let nsPrefix = prefix as NSString
        let match = nsPrefix.range(
            of: #"^(INT\.|EXT\.|INT\./EXT\.|EXT\./INT\.)\s+"#,
            options: [.regularExpression, .caseInsensitive]
        )
        guard match.location != NSNotFound else { return nil }

        let locationStart = lineStart + match.location + match.length
        let locationEnd: Int
        if let dashRange = prefix.range(of: " - ") {
            locationEnd = lineStart + (prefix as NSString).range(of: String(prefix[..<dashRange.lowerBound])).length
        } else {
            locationEnd = cursorLocation
        }
        return EditorTextRange(location: locationStart, length: max(0, locationEnd - locationStart))
    }

    private func sceneHeadingTimeRange(in prefix: String, lineStart: Int) -> EditorTextRange? {
        guard let dashRange = prefix.range(of: " - ", options: .backwards) else { return nil }
        let nsPrefix = prefix as NSString
        let timeStart = nsPrefix.range(of: String(prefix[..<dashRange.upperBound])).length
        return EditorTextRange(location: lineStart + timeStart, length: nsPrefix.length - timeStart)
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
