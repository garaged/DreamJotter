import Foundation
import Testing
@testable import DreamJotterMac

@Suite("M12.5 Complete Spanish UI Localization")
struct LocalizationResourceTests {
    private let requiredTables = ["Localizable", "Errors", "Review", "Settings", "SpanishCorrections"]

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    @Test("Mexican and Latin American Spanish tables have identical complete key coverage")
    func localeTablesMatch() throws {
        for tableName in requiredTables {
            let mexico = try stringsTable(locale: "es-MX", table: tableName)
            let latinAmerica = try stringsTable(locale: "es-419", table: tableName)

            #expect(Set(mexico.keys) == Set(latinAmerica.keys))
            #expect(mexico.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
            #expect(latinAmerica.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
        }

        #expect(try stringsTable(locale: "es-MX", table: "Localizable").count >= 290)
    }

    @Test("All critical writer journeys have Spanish translations")
    func criticalWorkflowKeysExist() throws {
        let table = try stringsTable(locale: "es-MX", table: "Localizable")
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

    @Test("Supporting tables cover their presentation paths")
    func supportingTablesContainCriticalKeys() throws {
        let errors = try stringsTable(locale: "es-MX", table: "Errors")
        let review = try stringsTable(locale: "es-MX", table: "Review")
        let settings = try stringsTable(locale: "es-MX", table: "Settings")

        #expect(errors["DreamJotter could not open this project package."] != nil)
        #expect(errors["Choose another location or check file permissions."] != nil)
        #expect(review["Numbering levels"] == "Niveles de numeración")
        #expect(review["Page"] == "Página")
        #expect(settings["Quit and reopen DreamJotter after changing the language to update the entire interface."] != nil)
    }

    @Test("Reviewed Spanish copy corrections remain in place")
    func reviewedSpanishCopyCorrections() throws {
        for locale in ["es-MX", "es-419"] {
            let corrections = try stringsTable(locale: locale, table: "SpanishCorrections")

            #expect(corrections["Script"] == "Guión")
            #expect(corrections["Health Report"] == "Informe de estado")
            #expect(corrections["All severities"] == "Todos los niveles de gravedad")
            #expect(corrections["Open script TODO"] == "Abrir pendiente del guión")
            #expect(corrections["Success"] == "Éxito")
            #expect(corrections.values.allSatisfy { !$0.contains("guion") })
        }
    }

    @Test("Spanish locale names are region appropriate")
    func localeNames() throws {
        let mexico = try stringsTable(locale: "es-MX", table: "Localizable")
        let latinAmerica = try stringsTable(locale: "es-419", table: "Localizable")

        #expect(mexico["Spanish (Latin America)"] == "Español (México y Latinoamérica)")
        #expect(latinAmerica["Spanish (Latin America)"] == "Español (Latinoamérica)")
    }

    @MainActor
    @Test("Application language override persists for the whole app")
    func applicationLanguagePreferencePersists() {
        let suiteName = "DreamJotter.LocalizationResourceTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = LocalizationSettings(defaults: defaults)
        #expect(settings.preference == .system)

        settings.preference = .spanishLatinAmerica
        let restored = LocalizationSettings(defaults: defaults)
        let processLanguageKey = ["Apple", "Languages"].joined()
        let processLanguages = defaults.stringArray(forKey: processLanguageKey)

        #expect(restored.preference == .spanishLatinAmerica)
        #expect(restored.locale.identifier == "es-MX")
        #expect(processLanguages == ["es-MX", "es-419", "es"])
    }

    private func stringsTable(locale: String, table: String) throws -> [String: String] {
        let url = repositoryRoot
            .appendingPathComponent("Apps/DreamJotterMac/Resources")
            .appendingPathComponent("\(locale).lproj/\(table).strings")
        let data = try Data(contentsOf: url)
        let propertyList = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return try #require(propertyList as? [String: String])
    }
}
