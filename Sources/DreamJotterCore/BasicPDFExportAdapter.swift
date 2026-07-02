import Foundation

/// Compatibility facade retained for the M9 export workflow entry point.
///
/// The former single-page basic renderer has been removed. All PDF output now
/// uses `PDFLayoutPlanner` and `ProductionPDFRenderer`.
public enum BasicPDFExportAdapter {
    public static func render(
        project: DreamJotterProject,
        preset: ExportPreset,
        generatedAt _: Date = Date()
    ) -> Data {
        ProductionPDFRenderer.render(project: project, preset: preset)
    }
}
