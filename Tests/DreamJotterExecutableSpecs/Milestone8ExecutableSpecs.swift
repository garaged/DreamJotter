import DreamJotterCore
import Foundation
import SpecSupport
import Testing

@Suite("Milestone 8 Executable Specs")
struct Milestone8ExecutableSpecs {
    @Test("Required character workflow specs exist")
    func requiredCharacterWorkflowSpecsExist() throws {
        let requiredFiles = [
            "docs/milestones/milestone-8-character-location-notes-scene-workflow.md",
            "docs/acceptance/milestone-8-acceptance.md",
            "docs/specs/characters/character-workflow.spec.md",
            "docs/specs/characters/detected-character-resolution.spec.md",
            "docs/specs/locations/location-workflow.spec.md",
            "docs/specs/locations/detected-location-resolution.spec.md",
            "docs/specs/scenes/scene-card-workflow.spec.md",
            "docs/specs/notes/notes-workflow.spec.md",
            "docs/specs/dashboard/project-dashboard-workflow.spec.md",
            "docs/data-contracts/character-profile.md",
            "docs/data-contracts/detected-character.md",
            "docs/data-contracts/location-profile.md",
            "docs/data-contracts/detected-location.md",
            "docs/data-contracts/scene-card.md",
            "docs/data-contracts/project-note.md",
            "docs/data-contracts/project-workspace-summary.md"
        ]

        for path in requiredFiles {
            #expect(try SpecRepository.pathExists(path))
        }
    }

    @Test("Detected character appears unresolved when no matching profile exists")
    func detectedCharacterAppearsUnresolvedWhenNoMatchingProfileExists() {
        let project = projectWithScript("""
        INT. APARTMENT - MORNING

        SOFIA
        I kept the letter.
        """)

        let detections = CharacterManager.detectedCharacters(for: project)

        #expect(detections == [
            DetectedCharacter(
                id: "detected-character-SOFIA",
                name: "SOFIA",
                normalizedName: "SOFIA",
                firstElementID: "element-2",
                occurrenceCount: 1,
                isGenericRole: false,
                resolutionStatus: .unresolved
            )
        ])
    }

    @Test("Converting detected character creates manual profile")
    func convertingDetectedCharacterCreatesManualProfile() {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let project = projectWithScript("""
        INT. APARTMENT - MORNING

        SOFIA
        I kept the letter.
        """, now: now)

        let converted = CharacterManager.convertDetectedCharacter(named: "SOFIA", in: project, now: now.addingTimeInterval(10))

        #expect(converted.characters == [
            CharacterRecord(
                id: "character-sofia",
                displayName: "SOFIA",
                normalizedKey: "SOFIA",
                source: .manual,
                createdAt: now.addingTimeInterval(10),
                updatedAt: now.addingTimeInterval(10)
            )
        ])
        #expect(CharacterManager.unresolvedDetectedCharacters(for: converted).isEmpty)
        #expect(converted.metadata.modifiedAt == now.addingTimeInterval(10))
    }

    @Test("Ignoring generic detected character suppresses unresolved entry")
    func ignoringGenericDetectedCharacterSuppressesUnresolvedEntry() throws {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let project = projectWithScript("""
        EXT. STREET - NIGHT

        MAN
        Wait here.
        """, now: now)

        let before = try #require(CharacterManager.detectedCharacters(for: project).first)
        #expect(before.name == "MAN")
        #expect(before.isGenericRole)
        #expect(before.resolutionStatus == .unresolved)

        let ignored = CharacterManager.ignoreDetectedCharacter(named: "MAN", in: project, now: now.addingTimeInterval(20))
        let after = try #require(CharacterManager.detectedCharacters(for: ignored).first)

        #expect(after.resolutionStatus == .ignored)
        #expect(CharacterManager.unresolvedDetectedCharacters(for: ignored).isEmpty)
        #expect(ignored.ignoredDetectedCharacterKeys == ["MAN"])
    }

    @Test("Existing profile resolves detected character")
    func existingProfileResolvesDetectedCharacter() throws {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let profile = CharacterRecord(
            id: "character-sofia",
            displayName: "SOFIA",
            normalizedKey: "SOFIA",
            createdAt: now,
            updatedAt: now
        )
        let project = projectWithScript("""
        INT. APARTMENT - MORNING

        SOFIA
        I kept the letter.
        """, characters: [profile], now: now)

        let detection = try #require(CharacterManager.detectedCharacters(for: project).first)

        #expect(detection.resolutionStatus == .matchedProfile)
        #expect(detection.matchedCharacterID == "character-sofia")
        #expect(CharacterManager.unresolvedDetectedCharacters(for: project).isEmpty)
    }

    @Test("Detected character resolution is safe for malformed uppercase text")
    func detectedCharacterResolutionIsSafeForMalformedUppercaseText() {
        let project = projectWithScript("""
        INT. APARTMENT - MORNING

        WARNING SIGN
        """)

        #expect(CharacterManager.detectedCharacters(for: project).isEmpty)
    }

    @Test("Detected character preserves unicode and collapses duplicates")
    func detectedCharacterPreservesUnicodeAndCollapsesDuplicates() throws {
        let project = projectWithScript("""
        INT. CASA - NOCHE

        NIÑA
        ¿Dónde está José?

        NIÑA
        No lo sé.
        """)

        let detection = try #require(CharacterManager.detectedCharacters(for: project).first)

        #expect(detection.name == "NIÑA")
        #expect(detection.normalizedName == "NINA")
        #expect(detection.occurrenceCount == 2)
        #expect(CharacterManager.detectedCharacters(for: project).count == 1)
    }

    @Test("Ignored detected character persists through dreamjotter package save and load")
    func ignoredDetectedCharacterPersistsThroughPackageSaveAndLoad() throws {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let project = projectWithScript("""
        EXT. STREET - NIGHT

        MAN
        Wait here.
        """, now: now)
        let ignored = CharacterManager.ignoreDetectedCharacter(named: "MAN", in: project, now: now.addingTimeInterval(20))
        let packageURL = temporaryPackageURL()

        try DreamJotterPackageStore.save(ignored, to: packageURL, updatedAt: now.addingTimeInterval(30))
        let result = DreamJotterPackageStore.load(from: packageURL)
        let loaded = try #require(result.project)

        #expect(loaded.ignoredDetectedCharacterKeys == ["MAN"])
        #expect(CharacterManager.unresolvedDetectedCharacters(for: loaded).isEmpty)
    }

    @Test("Detected location converts to profile and ignores duplicates")
    func detectedLocationConvertsToProfileAndIgnoresDuplicates() throws {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let project = projectWithScript("""
        INT. COFFEE SHOP - DAY

        Quiet.

        EXT. COFFEE SHOP - NIGHT

        Empty tables.
        """, now: now)

        let detection = try #require(LocationManager.unresolvedDetectedLocations(for: project).first)
        #expect(detection.name == "COFFEE SHOP")
        #expect(detection.sceneCount == 2)

        let converted = LocationManager.convertDetectedLocation(named: detection.name, in: project, now: now.addingTimeInterval(10))

        #expect(converted.locations.map(\.displayName) == ["COFFEE SHOP"])
        #expect(LocationManager.unresolvedDetectedLocations(for: converted).isEmpty)
    }

    @Test("Ignored detected location persists through package save and load")
    func ignoredDetectedLocationPersistsThroughPackageSaveAndLoad() throws {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let project = projectWithScript("INT. CAFÉ - NOCHE", now: now)
        let ignored = LocationManager.ignoreDetectedLocation(named: "CAFÉ", in: project, now: now.addingTimeInterval(20))
        let packageURL = temporaryPackageURL()

        try DreamJotterPackageStore.save(ignored, to: packageURL, updatedAt: now.addingTimeInterval(30))
        let loaded = try #require(DreamJotterPackageStore.load(from: packageURL).project)

        #expect(loaded.ignoredDetectedLocationKeys == ["CAFE"])
        #expect(LocationManager.unresolvedDetectedLocations(for: loaded).isEmpty)
    }

    @Test("Scene cards keep user status while derived heading updates")
    func sceneCardsKeepUserStatusWhileDerivedHeadingUpdates() throws {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let project = projectWithScript("""
        INT. ROOM - DAY

        SOFIA
        We stay.
        """, now: now)

        let updated = SceneCardBuilder.updateStatus(.needsRewrite, forSceneHeading: "INT. ROOM - DAY", in: project, now: now.addingTimeInterval(10))
        let card = try #require(SceneCardBuilder.cards(for: updated).first)

        #expect(card.title == "INT. ROOM - DAY")
        #expect(card.location == "ROOM")
        #expect(card.timeOfDay == "DAY")
        #expect(card.characters == ["SOFIA"])
        #expect(card.status == .needsRewrite)
        #expect(updated.metadata.modifiedAt == now.addingTimeInterval(10))
    }

    @Test("Notes workflow supports open resolved and parsed TODO notes")
    func notesWorkflowSupportsOpenResolvedAndParsedTodos() throws {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let note = ProjectNote(
            id: "note-1",
            body: "Rewrite the ending.",
            links: [NoteLink(targetKind: .project, targetID: "project-m8")],
            createdAt: now,
            updatedAt: now
        )
        let project = projectWithScript("""
        INT. ROOM - DAY

        [[TODO: improve this dialogue]]
        """, notes: [note], now: now)

        let todo = try #require(NotesIndex.detectedScriptTodos(in: project, now: now).first)
        #expect(todo.body == "improve this dialogue")
        #expect(todo.source == .parsedScriptTodo)

        let resolved = NotesIndex.resolve(noteID: "note-1", in: project, now: now.addingTimeInterval(10))
        #expect(NotesIndex.openNotes(in: resolved).isEmpty)
        #expect(resolved.notes.first?.status == .resolved)
    }

    @Test("Dashboard summary and search include M8 project objects")
    func dashboardSummaryAndSearchIncludeM8Objects() {
        let now = Date(timeIntervalSince1970: 1_783_468_800)
        let character = CharacterRecord(id: "character-elena", displayName: "ELENA", createdAt: now, updatedAt: now)
        let location = LocationRecord(id: "location-coffee-shop", displayName: "COFFEE SHOP", createdAt: now, updatedAt: now)
        let note = ProjectNote(id: "note-rewrite", body: "Rewrite the midpoint.", createdAt: now, updatedAt: now)
        let project = projectWithScript(
            "INT. COFFEE SHOP - DAY",
            characters: [character],
            locations: [location],
            notes: [note],
            now: now
        )

        let summary = ProjectWorkspaceSummaryBuilder.summary(for: project, isDirty: true, lastSavedAt: now)
        #expect(summary.sceneCount == 1)
        #expect(summary.characterProfileCount == 1)
        #expect(summary.locationProfileCount == 1)
        #expect(summary.openNotesCount == 1)
        #expect(summary.isDirty)

        #expect(ProjectSearch.search("ele", in: project).contains { $0.type == .character })
        #expect(ProjectSearch.search("coffee", in: project).contains { $0.type == .location })
        #expect(ProjectSearch.search("rewrite", in: project).contains { $0.type == .note })
    }

    private func projectWithScript(
        _ text: String,
        characters: [CharacterRecord] = [],
        locations: [LocationRecord] = [],
        notes: [ProjectNote] = [],
        now: Date = Date(timeIntervalSince1970: 1_783_468_800)
    ) -> DreamJotterProject {
        DreamJotterProject(
            metadata: metadata(title: "M8 Test", now: now),
            screenplay: ScreenplayParser.parse(text),
            characters: characters,
            locations: locations,
            notes: notes
        )
    }

    private func metadata(title: String, now: Date) -> ProjectMetadata {
        ProjectMetadata(
            id: "project-m8",
            title: title,
            createdAt: now,
            modifiedAt: now,
            schemaVersion: ProjectFactory.currentSchemaVersion,
            primaryScreenplayID: "screenplay-m8"
        )
    }

    private func temporaryPackageURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("DreamJotterM8-\(UUID().uuidString)")
            .appendingPathExtension("dreamjotter")
    }
}
