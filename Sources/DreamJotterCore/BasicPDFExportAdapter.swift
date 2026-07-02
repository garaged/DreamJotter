import Foundation

/// Compatibility facade retained for source compatibility with the M9 export API.
///
/// The former single-page renderer has been removed. All PDF output is planned by
/// `PDFLayoutPlanner` and rendered by `ProductionPDFRenderer`. New code should call
/// `ProductionPDFRenderer` directly.
@available(*, deprecated, message: "Use ProductionPDFRenderer; BasicPDFExportAdapter is retained only for compatibility.")
public enum BasicPDFExportAdapter {
    public static func render(
        project: DreamJotterProject,
        preset: ExportPreset,
        generatedAt _: Date = Date()
    ) -> Data {
        ProductionPDFRenderer.render(project: project, preset: preset)
    }
}
