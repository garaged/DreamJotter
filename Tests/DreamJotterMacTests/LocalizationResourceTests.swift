import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M12.5 Complete Spanish UI Localization")
struct LocalizationResourceTests {
    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test("Mexican and Latin American Spanish tables have identical complete key coverage")
    func localeTablesMatch() throws {
        let mexico = try stringsTable(locale: "es-MX")
        let latinAmerica = try stringsTable(locale: "es-419")

        #expect(mexico.count >= 290)
        #expect(Set(mexico.keys) == Set(latinAmerica.keys))
        #expect(mexico.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        #expect(latinAmerica.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
    }

    @Test("All critical writer journeys have Spanish translations")
    func criticalWorkflowKeysExist() throws {
        let table = try stringsTable(locale: "es-MX")
        let required: Set<String> = [
            "New Project", "Open DreamJotter Package", "Save DreamJotter Package",
            "Dashboard", "Script", "Characters", "Locations", "Scenes", "Notes",
            "Review Mode", "Health Report", "Export Project", "Create DreamJotter Backup",
            "Restore DreamJotter Backup", "Unsaved Changes", "Discard Changes",
            "Screenplay Language", "Spanish (Latin America)", "Find in script",
            "Add Character", "Add Location", "Add Manual Note", "Save Scene Card",
            "Apply Planning Order to Script", "Review Findings", "Reveal in Finder"
        ]

        #expect(required.isSubset(of: Set(table.keys)))
    }

    @Test("Spanish locale names are region appropriate")
    func localeNames() throws {
        let mexico = try stringsTable(locale: "es-MX")
        let latinAmerica = try stringsTable(locale: "es-419")

        #expect(mexico["Spanish (Latin America)"] == "Español (México y Latinoamérica)")
        #expect(latinAmerica["Spanish (Latin America)"] == "Español (Latinoamérica)")
    }

    @MainActor
    @Test("Application language override persists")
    func applicationLanguagePreferencePersists() {
        let suiteName = "DreamJotter.LocalizationResourceTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = LocalizationSettings(defaults: defaults)
        #expect(settings.preference == .system)

        settings.preference = .spanishLatinAmerica
        let restored = LocalizationSettings(defaults: defaults)
        #expect(restored.preference == .spanishLatinAmerica)
        #expect(restored.locale.identifier == "es-MX")
    }

    private func stringsTable(locale: String) throws -> [String: String] {
        let url = repositoryRoot
            .appendingPathComponent("Apps/DreamJotterMac/Resources")
            .appendingPathComponent("\(locale).lproj/Localizable.strings")
        let data = try Data(contentsOf: url)
        let propertyList = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return try #require(propertyList as? [String: String])
    }
}
