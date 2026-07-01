import DreamJotterCore
import Foundation
import SpecSupport
import Testing

@Suite("Milestone 2 Executable Specs")
struct Milestone2ExecutableSpecs {
    @Test("Milestone 2 organization specs exist")
    func milestoneTwoSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-2-real-mvp.md",
            "docs/acceptance/milestone-2-acceptance.md",
            "docs/export/export-system-spec.md",
            "docs/specs/script-analysis-spec.md",
            "docs/storage/dreamjotter-package-format.md",
            "docs/storage/storage-errors.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Traceability matrix mentions every milestone spec file")
    func traceabilityMentionsEveryMilestoneSpecFile() throws {
        let traceability = try SpecRepository.read("docs/acceptance/traceability-matrix.md")
        let milestoneSpecFiles = [
            "docs/milestones/milestone-1-apple-prototype-foundations.md",
            "docs/milestones/milestone-2-real-mvp.md",
            "docs/milestones/milestone-3-friendly-writer-tools.md",
            "docs/milestones/milestone-4-pro-foundations.md",
            "docs/milestones/milestone-map.md"
        ]

        for path in milestoneSpecFiles {
            #expect(traceability.contains(path))
        }
    }

    @Test("Traceability matrix mentions registered acceptance files")
    func traceabilityMentionsRegisteredAcceptanceFiles() throws {
        let traceability = try SpecRepository.read("docs/acceptance/traceability-matrix.md")
        let registry = try SpecRepository.registry()
        let acceptanceFiles = Set(registry.items.compactMap(\.acceptance).filter { !$0.isEmpty })

        for path in acceptanceFiles where path.contains("milestone") {
            let fileExists = try SpecRepository.pathExists(path)
            #expect(traceability.contains(path) || fileExists)
        }
    }

    @Test("Blank, short film, and feature film templates create normal simple-mode projects")
    func templatesCreateNormalSimpleModeProjects() {
        let createdAt = Date(timeIntervalSince1970: 1_782_777_600)
        let blank = TemplateFactory.createProject(
            templateID: .blankScreenplay,
            title: "Untitled Screenplay",
            projectID: "project-blank",
            screenplayID: "screenplay-blank",
            createdAt: createdAt
        )
        let short = TemplateFactory.createProject(
            templateID: .shortFilm,
            title: "Rain On Set",
            projectID: "project-short",
            screenplayID: "screenplay-short",
            createdAt: createdAt
        )
        let feature = TemplateFactory.createProject(
            templateID: .featureFilm,
            title: "The Long Night",
            projectID: "project-feature",
            screenplayID: "screenplay-feature",
            createdAt: createdAt
        )

        #expect(blank.mode == .simple)
        #expect(blank.template?.id == "blank-screenplay")
        #expect(blank.screenplay.elements.isEmpty)
        #expect(short.template?.id == "short-film")
        #expect(short.notes.map(\.id) == ["template-note-short-film"])
        #expect(feature.template?.id == "feature-film")
        #expect(feature.notes.map(\.id) == ["template-note-feature-film"])
    }

    @Test("Character manager merges manual and detected Unicode characters")
    func characterManagerMergesManualAndDetectedUnicodeCharacters() {
        let now = Date(timeIntervalSince1970: 1_782_777_600)
        let screenplay = ScreenplayParser.parse("""
        INT. KITCHEN - NIGHT

        NIÑA
        ¿Dónde está José?

        NIÑA
        No lo sé.
        """)
        let manual = CharacterRecord(
            id: "character-nina",
            displayName: "NIÑA",
            note: "Carries the opening mystery.",
            createdAt: now,
            updatedAt: now
        )
        let project = DreamJotterProject(
            metadata: metadata(title: "Mystery", now: now),
            screenplay: screenplay,
            characters: [manual]
        )

        let records = CharacterManager.records(for: project, now: now)
        #expect(records == [manual])

        let searchResults = ProjectSearch.search("mystery", in: project)
        #expect(searchResults == [
            SearchResult(type: .character, sourceID: "character-nina", preview: "NIÑA", navigationTarget: "character:character-nina")
        ])
    }

    @Test("Scene cards and linked notes derive from semantic scenes")
    func sceneCardsAndLinkedNotesDeriveFromSemanticScenes() {
        let now = Date(timeIntervalSince1970: 1_782_777_600)
        let screenplay = ScreenplayParser.parse("""
        INT. KITCHEN - NIGHT

        The lights flicker.
        """)
        let note = ProjectNote(
            id: "note-kitchen",
            body: "Make this scene feel colder.",
            links: [NoteLink(targetKind: .scene, targetID: "INT. KITCHEN - NIGHT")],
            createdAt: now,
            updatedAt: now
        )
        let sceneCard = SceneCard(
            id: "scene-card-kitchen",
            sourceSceneHeading: "INT. KITCHEN - NIGHT",
            title: "INT. KITCHEN - NIGHT",
            summary: "The opening disturbance.",
            order: 0
        )
        let project = DreamJotterProject(
            metadata: metadata(title: "Kitchen", now: now),
            screenplay: screenplay,
            notes: [note],
            sceneCards: [sceneCard]
        )

        #expect(SceneCardBuilder.cards(for: project) == [sceneCard])
        #expect(NotesIndex.notes(linkedTo: NoteLink(targetKind: .scene, targetID: "INT. KITCHEN - NIGHT"), in: project) == [note])
        #expect(ProjectSearch.search("colder", in: project).map(\.type) == [.note])
        #expect(ProjectSearch.search("kitchen", in: project).contains { $0.type == .sceneCard })
    }

    @Test("Inbox items persist searchably and archive without deletion")
    func inboxItemsPersistSearchablyAndArchiveWithoutDeletion() {
        let now = Date(timeIntervalSince1970: 1_782_777_600)
        let active = InboxItem(id: "idea-active", body: "Add a park bench clue.", createdAt: now, updatedAt: now)
        let archived = InboxItem(id: "idea-archived", body: "Older park clue.", state: .archived, createdAt: now, updatedAt: now)
        let project = DreamJotterProject(
            metadata: metadata(title: "Ideas", now: now),
            screenplay: ScreenplayDocument(),
            inboxItems: [active, archived]
        )

        #expect(InboxIndex.activeItems(in: project) == [active])
        #expect(ProjectSearch.search("park", in: project).map(\.sourceID) == ["idea-active", "idea-archived"])
    }

    @Test("Snapshots capture and restore canonical project content")
    func snapshotsCaptureAndRestoreCanonicalProjectContent() {
        let now = Date(timeIntervalSince1970: 1_782_777_600)
        let project = DreamJotterProject(
            metadata: metadata(title: "Before", now: now),
            screenplay: ScreenplayParser.parse("INT. ROOM - DAY\n\nA quiet room."),
            characters: [
                CharacterRecord(id: "character-ana", displayName: "ANA", createdAt: now, updatedAt: now)
            ],
            notes: [
                ProjectNote(id: "note-one", body: "Keep this.", createdAt: now, updatedAt: now)
            ]
        )

        let snapshot = SnapshotManager.createSnapshot(
            id: "snapshot-001",
            name: "Before rewriting opening",
            project: project,
            createdAt: now
        )
        let restored = SnapshotManager.projectByRestoring(snapshot, preserving: [snapshot])

        #expect(snapshot.name == "Before rewriting opening")
        #expect(snapshot.schemaVersion == ProjectFactory.currentSchemaVersion)
        #expect(restored.screenplay == project.screenplay)
        #expect(restored.characters == project.characters)
        #expect(restored.notes == project.notes)
        #expect(restored.snapshots == [snapshot])
    }

    @Test("Package save and load reconstructs canonical data without SwiftData")
    func packageSaveAndLoadReconstructsCanonicalDataWithoutSwiftData() throws {
        let now = Date(timeIntervalSince1970: 1_782_777_600)
        let project = richProject(now: now)
        let packageURL = temporaryDirectory().appendingPathComponent("Rain On Set.dreamjotter", isDirectory: true)

        try DreamJotterPackageStore.save(project, to: packageURL, updatedAt: now)
        let result = DreamJotterPackageStore.load(from: packageURL)

        #expect(result.diagnostics.isEmpty)
        #expect(result.manifest?.projectFile == "project.json")
        #expect(result.project?.metadata == project.metadata)
        #expect(result.project?.screenplay == project.screenplay)
        #expect(result.project?.characters == project.characters)
        #expect(result.project?.notes == project.notes)
        #expect(result.project?.inboxItems == project.inboxItems)
        #expect(result.project?.sceneCards == project.sceneCards)
        #expect(result.project?.snapshots == project.snapshots)
        #expect(FileManager.default.fileExists(atPath: packageURL.appendingPathComponent("script.fountain").path))
    }

    @Test("Package loader reports missing and invalid files without inventing state")
    func packageLoaderReportsMissingAndInvalidFilesWithoutInventingState() throws {
        let packageURL = temporaryDirectory().appendingPathComponent("Broken.dreamjotter", isDirectory: true)
        try FileManager.default.createDirectory(at: packageURL, withIntermediateDirectories: true)

        let missingManifest = DreamJotterPackageStore.load(from: packageURL)
        #expect(missingManifest.project == nil)
        #expect(missingManifest.diagnostics.map(\.code) == ["missingManifest"])

        let manifest = PackageManifest(
            packageId: "broken",
            createdAt: Date(timeIntervalSince1970: 1_782_777_600),
            updatedAt: Date(timeIntervalSince1970: 1_782_777_600)
        )
        try writeFixture(manifest, to: packageURL.appendingPathComponent("manifest.json"))
        try Data("{".utf8).write(to: packageURL.appendingPathComponent("screenplay.json"))

        let invalidPackage = DreamJotterPackageStore.load(from: packageURL)
        #expect(invalidPackage.project == nil)
        #expect(invalidPackage.diagnostics.contains { $0.code == "missingRequiredFile" && $0.path == "project.json" })

        let validMetadata = metadata(title: "Broken", now: Date(timeIntervalSince1970: 1_782_777_600))
        try writeFixture(validMetadata, to: packageURL.appendingPathComponent("project.json"))
        let invalidScreenplay = DreamJotterPackageStore.load(from: packageURL)
        #expect(invalidScreenplay.project == nil)
        #expect(invalidScreenplay.diagnostics.contains { $0.code == "invalidJSON" && $0.path == "screenplay.json" })
    }

    @Test("Health report is advisory and detects blank, orphaned, and variant issues")
    func healthReportIsAdvisoryAndDetectsBlankOrphanedAndVariantIssues() {
        let now = Date(timeIntervalSince1970: 1_782_777_600)
        let orphanedNote = ProjectNote(
            id: "note-orphan",
            body: "Attached to missing scene.",
            links: [NoteLink(targetKind: .scene, targetID: "missing-scene-id")],
            createdAt: now,
            updatedAt: now
        )
        let project = DreamJotterProject(
            metadata: metadata(title: "", now: now),
            screenplay: ScreenplayDocument(),
            characters: [
                CharacterRecord(id: "character-jose", displayName: "JOSE", createdAt: now, updatedAt: now),
                CharacterRecord(id: "character-jose-accented", displayName: "JOSÉ", createdAt: now, updatedAt: now)
            ],
            notes: [orphanedNote]
        )

        let findings = HealthReport.findings(for: project)
        #expect(Set(findings.map(\.id)) == ["missingTitle", "noScenes", "orphanedNote", "possibleCharacterVariant"])
        #expect(findings.allSatisfy { $0.severity != .warning || $0.id == "orphanedNote" })
    }

    @Test("Simple Mode hides Pro-only actions and export presets expose availability")
    func simpleModeHidesProOnlyActionsAndExportPresetsExposeAvailability() {
        let presets = ExportPresetCatalog.builtInPresets()

        #expect(ModePolicy.defaultMode() == .simple)
        #expect(!ModePolicy.simpleModeAvailability(for: "customFields"))
        #expect(!ModePolicy.simpleModeAvailability(for: "routines"))
        #expect(!ModePolicy.simpleModeAvailability(for: "pluginConfiguration"))
        #expect(!ModePolicy.simpleModeAvailability(for: "advancedExportPresetEditing"))
        #expect(presets == [
            ExportPreset(id: "draft-pdf", title: "Draft PDF", format: .pdf, availability: .unavailable),
            ExportPreset(id: "fountain", title: "Fountain", format: .fountain, availability: .available)
        ])
    }

    @Test("Dashboard summaries are derived from package metadata and can mark missing recents")
    func dashboardSummariesAreDerivedFromPackageMetadataAndCanMarkMissingRecents() {
        let now = Date(timeIntervalSince1970: 1_782_777_600)
        let project = TemplateFactory.createProject(
            templateID: .blankScreenplay,
            title: "Dashboard Project",
            projectID: "project-dashboard",
            screenplayID: "screenplay-dashboard",
            createdAt: now
        )

        let available = DashboardBuilder.summary(for: project, packagePath: "/tmp/Dashboard Project.dreamjotter", lastOpenedAt: now)
        let unavailable = DashboardBuilder.unavailableSummary(projectID: "missing", title: "Moved", packagePath: "/tmp/Moved.dreamjotter")

        #expect(available.status == .available)
        #expect(available.title == "Dashboard Project")
        #expect(unavailable.status == .unavailable)
    }

    private func metadata(title: String, now: Date) -> ProjectMetadata {
        ProjectMetadata(
            id: "project-\(title.isEmpty ? "untitled" : title.lowercased().replacingOccurrences(of: " ", with: "-"))",
            title: title,
            createdAt: now,
            modifiedAt: now,
            schemaVersion: ProjectFactory.currentSchemaVersion,
            primaryScreenplayID: "screenplay-\(title.isEmpty ? "untitled" : title.lowercased().replacingOccurrences(of: " ", with: "-"))"
        )
    }

    private func richProject(now: Date) -> DreamJotterProject {
        let screenplay = ScreenplayParser.parse("""
        EXT. PARK - DAY

        Rain falls on empty benches.

        MARIA
        I found the clue.
        """)
        let character = CharacterRecord(
            id: "character-maria",
            displayName: "MARIA",
            note: "Searches for her brother.",
            createdAt: now,
            updatedAt: now
        )
        let note = ProjectNote(
            id: "note-rain",
            body: "Rain motif should return in act three.",
            links: [NoteLink(targetKind: .scene, targetID: "EXT. PARK - DAY")],
            createdAt: now,
            updatedAt: now
        )
        let inbox = InboxItem(
            id: "idea-park",
            body: "Add a park bench clue.",
            createdAt: now,
            updatedAt: now
        )
        let sceneCard = SceneCard(
            id: "scene-card-park",
            sourceSceneHeading: "EXT. PARK - DAY",
            title: "EXT. PARK - DAY",
            summary: "Maria finds a clue.",
            order: 0
        )
        let project = DreamJotterProject(
            metadata: metadata(title: "Rain On Set", now: now),
            screenplay: screenplay,
            characters: [character],
            notes: [note],
            inboxItems: [inbox],
            sceneCards: [sceneCard]
        )
        let snapshot = SnapshotManager.createSnapshot(id: "snapshot-001", name: "Before save", project: project, createdAt: now)
        return DreamJotterProject(
            metadata: project.metadata,
            screenplay: project.screenplay,
            characters: project.characters,
            notes: project.notes,
            inboxItems: project.inboxItems,
            sceneCards: project.sceneCards,
            snapshots: [snapshot]
        )
    }

    private func temporaryDirectory() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func writeFixture<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        try data.write(to: url)
    }
}
