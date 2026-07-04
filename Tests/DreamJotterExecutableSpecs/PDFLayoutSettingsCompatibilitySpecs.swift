import DreamJotterCore
import Foundation
import Testing

@Suite("PDF layout settings compatibility")
struct PDFLayoutSettingsCompatibilitySpecs {
    @Test("Legacy settings decode without extended numbering keys")
    func legacySettingsDecodeWithoutExtendedNumberingKeys() throws {
        let json = """
        {
          "pageSize": { "width": 612, "height": 792 },
          "margins": { "top": 72, "bottom": 72, "left": 90, "right": 72 },
          "lineHeight": 12,
          "charactersPerBodyLine": 60,
          "contentLinesPerPage": 54,
          "includeTitlePage": true,
          "includePageNumbers": true,
          "suppressIdentifyingMetadata": false
        }
        """

        let settings = try JSONDecoder().decode(
            PDFLayoutSettings.self,
            from: Data(json.utf8)
        )

        #expect(settings.includePageNumbers)
        #expect(settings.includeParagraphNumbers == false)
        #expect(settings.includeLineNumbers == false)
    }
}
