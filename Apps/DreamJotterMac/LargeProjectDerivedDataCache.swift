import DreamJotterCore
import Foundation

struct DerivedDataRevisionKey: Hashable, Sendable {
    let projectID: String
    let textRevision: Int
    let modifiedAt: Date
}

@MainActor
final class LargeProjectDerivedDataCache {
    static let shared = LargeProjectDerivedDataCache()

    private var healthReports: [DerivedDataRevisionKey: ScriptHealthReport] = [:]
    private var layoutPlans: [DerivedDataRevisionKey: PDFLayoutPlan] = [:]
    private var sceneCards: [DerivedDataRevisionKey: [SceneCard]] = [:]

    func healthReport(for key: DerivedDataRevisionKey) -> ScriptHealthReport? {
        healthReports[key]
    }

    func store(_ report: ScriptHealthReport, for key: DerivedDataRevisionKey) {
        healthReports[key] = report
        trimIfNeeded()
    }

    func layoutPlan(for key: DerivedDataRevisionKey) -> PDFLayoutPlan? {
        layoutPlans[key]
    }

    func store(_ plan: PDFLayoutPlan, for key: DerivedDataRevisionKey) {
        layoutPlans[key] = plan
        trimIfNeeded()
    }

    func sceneCards(for key: DerivedDataRevisionKey) -> [SceneCard]? {
        sceneCards[key]
    }

    func store(_ cards: [SceneCard], for key: DerivedDataRevisionKey) {
        sceneCards[key] = cards
        trimIfNeeded()
    }

    func invalidate(projectID: String) {
        healthReports = healthReports.filter { $0.key.projectID != projectID }
        layoutPlans = layoutPlans.filter { $0.key.projectID != projectID }
        sceneCards = sceneCards.filter { $0.key.projectID != projectID }
    }

    private func trimIfNeeded() {
        let maximumEntries = 12
        if healthReports.count > maximumEntries { healthReports.removeValue(forKey: healthReports.keys.first!) }
        if layoutPlans.count > maximumEntries { layoutPlans.removeValue(forKey: layoutPlans.keys.first!) }
        if sceneCards.count > maximumEntries { sceneCards.removeValue(forKey: sceneCards.keys.first!) }
    }
}

enum LargeProjectPreview {
    static let maximumCharacters = 24_000

    static func make(from text: String) -> (text: String, isTruncated: Bool) {
        guard text.count > maximumCharacters else { return (text, false) }
        return (String(text.prefix(maximumCharacters)), true)
    }
}

extension ProjectDocumentViewModel {
    var derivedDataRevisionKey: DerivedDataRevisionKey {
        DerivedDataRevisionKey(
            projectID: project.metadata.id,
            textRevision: editorParseState.currentTextRevision,
            modifiedAt: project.metadata.modifiedAt
        )
    }
}
