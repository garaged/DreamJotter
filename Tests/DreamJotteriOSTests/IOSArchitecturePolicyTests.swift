import DreamJotteriOS
import Testing

@Suite("iOS architecture policies")
struct IOSArchitecturePolicyTests {
    @Test("desktop parity catalog contains each capability exactly once")
    func parityCatalogIsCompleteAndUnique() {
        let items = IOSFeatureParityCatalog.fullDesktopParity
        #expect(items.count == IOSCapability.allCases.count)
        #expect(Set(items.map(\.capability)).count == IOSCapability.allCases.count)
    }

    @Test("every delivery phase has owned capabilities")
    func everyPhaseHasCapabilities() {
        for phase in IOSDeliveryPhase.allCases {
            #expect(!IOSFeatureParityCatalog.items(in: phase).isEmpty)
        }
    }

    @Test("phone policy limits expensive derived state")
    func phonePolicyIsBounded() {
        let compact = IOSWorkspacePolicy.policy(for: .phoneCompact)
        let regular = IOSWorkspacePolicy.policy(for: .phoneRegular)

        #expect(compact.presentation == .singlePane)
        #expect(compact.editorHydration == .visibleWindow)
        #expect(compact.maximumCachedDerivedViews <= regular.maximumCachedDerivedViews)
        #expect(compact.maximumPreviewElements <= regular.maximumPreviewElements)
    }

    @Test("iPad regular width permits a persistent sidebar without hydrating the entire editor")
    func padPolicyKeepsEditorVirtualized() {
        let policy = IOSWorkspacePolicy.policy(for: .padRegular)
        #expect(policy.presentation == .persistentSidebar)
        #expect(policy.editorHydration == .visibleWindow)
        #expect(policy.maximumCachedDerivedViews == 6)
    }

    @Test("backgrounding always produces an immediate background save")
    func backgroundSaveIsImmediate() {
        let decision = IOSDocumentSessionPolicy.saveDecision(
            reason: .applicationBackgrounding,
            lifecycleState: .background
        )

        #expect(decision.urgency == .immediate)
        #expect(decision.requiresBackgroundTask)
        #expect(decision.mustCheckExternalGeneration)
    }

    @Test("active autosave is deferred and generation-safe")
    func activeAutosaveIsDebounced() {
        let decision = IOSDocumentSessionPolicy.saveDecision(
            reason: .autosaveDebounce,
            lifecycleState: .active
        )

        #expect(decision.urgency == .deferred)
        #expect(!decision.requiresBackgroundTask)
        #expect(decision.mustCheckExternalGeneration)
    }
}
