import DreamJotterCore
import Testing
@testable import DreamJotterMac

@Suite("Export Preset Presentation Tests")
struct ExportPresetPresentationTests {
    @Test("Legacy stored built-ins do not hide current built-ins")
    func legacyStoredBuiltInsDoNotHideCurrentBuiltIns() {
        let stored = [
            ExportPreset(id: "draft-pdf", title: "Draft PDF", format: .pdf, availability: .available),
            ExportPreset(id: "fountain", title: "Fountain", format: .fountain, availability: .available)
        ]
        let presented = ExportUIState.presentedPresets(stored)
        let ids = Set(presented.map(\.id))
        #expect(ids.contains("reader-copy"))
        #expect(ids.contains("print-script"))
        #expect(ids.contains("contest-submission"))
        #expect(ids.contains("plain-text-archive"))
        #expect(ids.contains("writer-backup"))
        #expect(ids.contains("draft-pdf") == false)
        #expect(ids.contains("fountain") == false)
    }

    @Test("Custom project presets remain available")
    func customProjectPresetsRemainAvailable() {
        let custom = ExportPreset(id: "custom-review-copy", title: "Custom Review Copy", format: .pdf, availability: .available, isBuiltIn: false, allowedFormats: [.pdf])
        let presented = ExportUIState.presentedPresets([custom])
        #expect(presented.contains { $0.id == custom.id })
    }

    @Test("Initial workspace export state prefers Reader Copy PDF")
    func initialStatePrefersCurrentReaderPreset() {
        let legacy = ExportPreset(id: "draft-pdf", title: "Draft PDF", format: .pdf, availability: .available)
        let state = ExportUIState.initial(presets: [legacy])
        #expect(state.selectedPresetID == "reader-copy")
        #expect(state.selectedFormat == .pdf)
    }

    @Test("Initial Review export state prefers page and paragraph numbered Print Script PDF")
    func reviewStatePrefersNumberedPrintPreset() throws {
        let state = ExportUIState.initial(sourceContext: .reviewMode)
        let preset = try #require(state.selectedPreset(in: ExportPresetCatalog.builtInPresets()))
        let settings = PDFLayoutSettings.defaults(for: preset)
        #expect(state.selectedPresetID == "print-script")
        #expect(state.selectedFormat == .pdf)
        #expect(settings.includePageNumbers)
        #expect(settings.includeParagraphNumbers)
        #expect(!settings.includeLineNumbers)
    }
}
