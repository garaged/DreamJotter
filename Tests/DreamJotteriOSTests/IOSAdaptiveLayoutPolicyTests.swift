import DreamJotteriOS
import Testing

@Suite("Adaptive iOS layout policy")
struct IOSAdaptiveLayoutPolicyTests {
    @Test("narrow phones resolve to compact single-pane layout")
    func compactPhone() {
        let metrics = IOSAdaptiveLayoutMetrics.resolve(
            availableWidth: 375,
            horizontalSizeClassIsCompact: true,
            idiomIsPad: false
        )

        #expect(metrics.layoutClass == .compactPhone)
        #expect(metrics.navigationMode == .singlePane)
        #expect(metrics.autocompleteMode == .compactFloatingCard)
        #expect(!metrics.showsCommandLabels)
        #expect(!metrics.showsKeyboardHelp)
    }

    @Test("wide phones remain focused single-pane workspaces")
    func regularPhone() {
        let metrics = IOSAdaptiveLayoutMetrics.resolve(
            availableWidth: 430,
            horizontalSizeClassIsCompact: true,
            idiomIsPad: false
        )

        #expect(metrics.layoutClass == .regularPhone)
        #expect(metrics.navigationMode == .singlePane)
        #expect(metrics.maximumReadableEditorWidth >= 600)
    }

    @Test("iPad split view uses collapsible navigation")
    func compactPad() {
        let metrics = IOSAdaptiveLayoutMetrics.resolve(
            availableWidth: 650,
            horizontalSizeClassIsCompact: true,
            idiomIsPad: true
        )

        #expect(metrics.layoutClass == .compactPad)
        #expect(metrics.navigationMode == .collapsibleSplit)
        #expect(metrics.showsCommandLabels)
        #expect(metrics.showsKeyboardHelp)
    }

    @Test("regular iPad uses persistent split navigation")
    func regularPad() {
        let metrics = IOSAdaptiveLayoutMetrics.resolve(
            availableWidth: 1_024,
            horizontalSizeClassIsCompact: false,
            idiomIsPad: true
        )

        #expect(metrics.layoutClass == .regularPad)
        #expect(metrics.navigationMode == .persistentSplit)
        #expect(metrics.preferredSidebarWidth >= 280)
        #expect(metrics.maximumReadableEditorWidth < 1_024)
    }

    @Test("layout metrics grow monotonically and remain bounded")
    func metricsAreBounded() {
        let compactPhone = IOSAdaptiveLayoutMetrics.metrics(for: .compactPhone)
        let regularPhone = IOSAdaptiveLayoutMetrics.metrics(for: .regularPhone)
        let compactPad = IOSAdaptiveLayoutMetrics.metrics(for: .compactPad)
        let regularPad = IOSAdaptiveLayoutMetrics.metrics(for: .regularPad)

        #expect(compactPhone.horizontalEditorInset > 0)
        #expect(compactPhone.horizontalEditorInset <= regularPhone.horizontalEditorInset)
        #expect(regularPhone.horizontalEditorInset <= compactPad.horizontalEditorInset)
        #expect(compactPad.horizontalEditorInset <= regularPad.horizontalEditorInset)
        #expect(compactPhone.autocompleteMaximumWidth <= regularPad.autocompleteMaximumWidth)
        #expect(regularPad.maximumReadableEditorWidth <= 900)
    }
}
