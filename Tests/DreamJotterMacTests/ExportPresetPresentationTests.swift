import DreamJotterCore
import Testing
@testable import DreamJotterMac

@Suite("Export Preset Presentation Tests")
struct ExportPresetPresentationTests {
    @Test("Legacy stored built-ins do not hide current built-ins")
    func legacyStoredBuiltInsDoNotHideCurrentBuiltIns() {
        let stored = [
            ExportPreset(
                id: "draft-pdf",
                title: "Draft PDF",
                format: .pdf,
                availability: .available
            ),
            ExportPreset(
                id: "fountain",
                title: "Fountain",
                format: .fountain,
                availability: .available
            )
        ]

        let presented = ExportUIState.presentedPresets(stored)
        let ids = Set(presented.map(\.id))

        #expect(ids.contains("reader-copy"))
        #expect(ids.contains("print-script"))
        #expect(ids.contains("contest-submission"))
        #expect(ids.contains("fountain"))
        #expect(ids.contains("writer-backup"))
        #expect(ids.contains("draft-pdf") == false)
    }

    @Test("Custom project presets remain available")
    func customProjectPresetsRemainAvailable() {
        let custom = ExportPreset(
            id: "custom-review-copy",
            title: "Custom Review Copy",
            format: .pdf,
            availability: .available,
            isBuiltIn: false,
            allowedFormats: [.pdf]
        )

        let presented = ExportUIState.presentedPresets([custom])

        #expect(presented.contains { $0.id == custom.id })
    }

    @Test("Initial export state prefers current reader preset")
    func initialStatePrefersCurrentReaderPreset() {
        let legacy = ExportPreset(
            id: "draft-pdf",
            title: "Draft PDF",
            format: .pdf,
            availability: .available
        )

        let state = ExportUIState.initial(presets: [legacy])

        #expect(state.selectedPresetID == "reader-copy")
        #expect(state.selectedFormat == .pdf)
    }
}
