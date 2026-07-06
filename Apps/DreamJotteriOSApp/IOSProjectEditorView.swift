import DreamJotterCore
import DreamJotteriOS
import SwiftUI
import UIKit

struct IOSProjectEditorView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var project: DreamJotterProject
    @State private var generation: IOSPackageGeneration
    @State private var session: IOSEditorSession
    @State private var visibleRange = EditorTextRange(location: 0, length: 0)
    @State private var autocomplete = IOSAutocompleteState()
    @State private var selectedPane: IOSWorkspacePane = .screenplay
    @State private var splitVisibility: NavigationSplitViewVisibility = .all
    @State private var showsNavigator = true
    @State private var showsInspector = true
    @State private var projectMutationRevision: UInt64 = 0
    @State private var errorMessage: String?

    private let packageURL: URL
    private let onClose: () -> Void
    private let documentAdapter = IOSProjectDocumentAdapter()

    init(snapshot: IOSProjectDocumentSnapshot, onClose: @escaping () -> Void = {}) {
        packageURL = snapshot.packageURL
        self.onClose = onClose
        _project = State(initialValue: snapshot.project)
        _generation = State(initialValue: snapshot.generation)
        _session = State(initialValue: IOSEditorSession(
            text: FountainIO.exportScreenplay(snapshot.project.screenplay)
        ))
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = IOSAdaptiveLayoutMetrics.resolve(
                availableWidth: proxy.size.width,
                horizontalSizeClassIsCompact: horizontalSizeClass == .compact,
                idiomIsPad: UIDevice.current.userInterfaceIdiom == .pad
            )
            layout(for: metrics, isLandscape: proxy.size.width > proxy.size.height)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(Color(uiColor: .systemBackground))
        .task(id: session.revision.value) {
            refreshAutocomplete()
            await parseCurrentRevision()
        }
        .task(id: session.autosaveRevisionPending?.value) {
            await autosaveCurrentRevision()
        }
        .task(id: projectMutationRevision) {
            guard projectMutationRevision > 0 else { return }
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }
            await saveWorkspaceProjectMutation()
        }
        .onChange(of: session.selection) { _, _ in refreshAutocomplete() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .background || phase == .inactive else { return }
            Task { await saveImmediatelyForLifecycleTransition() }
        }
        .alert("DreamJotter", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @ViewBuilder
    private func layout(for metrics: IOSAdaptiveLayoutMetrics, isLandscape: Bool) -> some View {
        switch metrics.layoutClass {
        case .compactPhone:
            compactPhoneWorkspace(metrics: metrics)
        case .regularPhone:
            regularPhoneWorkspace(metrics: metrics, isLandscape: isLandscape)
        case .compactPad:
            compactPadWorkspace(metrics: metrics)
        case .regularPad:
            regularPadWorkspace(metrics: metrics, isLandscape: isLandscape)
        }
    }

    private func compactPhoneWorkspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        VStack(spacing: 0) {
            compactHeader.frame(height: 44).background(.bar)
            workspaceSurface(metrics: metrics, inset: 0, radius: 0, shadow: 0)
        }
    }

    private func regularPhoneWorkspace(metrics: IOSAdaptiveLayoutMetrics, isLandscape: Bool) -> some View {
        Group {
            if isLandscape {
                VStack(spacing: 0) {
                    compactHeader.frame(height: 40).background(.bar)
                    workspaceSurface(metrics: metrics, inset: 0, radius: 0, shadow: 0)
                }
            } else {
                NavigationStack {
                    workspaceSurface(metrics: metrics, inset: 8, radius: 10, shadow: 3)
                        .navigationTitle(selectedPane == .screenplay ? project.metadata.title : selectedPane.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                HStack(spacing: 2) {
                                    Button(action: onClose) { Image(systemName: "chevron.backward") }
                                    workspaceMenu
                                }
                            }
                            if selectedPane == .screenplay {
                                ToolbarItemGroup(placement: .topBarTrailing) {
                                    Button(action: performSmartEnter) { Image(systemName: "return") }
                                    Button(action: performFormatCycle) { Image(systemName: "textformat") }
                                }
                            }
                        }
                }
            }
        }
    }

    private func compactPadWorkspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        NavigationSplitView(columnVisibility: $splitVisibility) {
            projectNavigator(showInspectorSummary: false)
                .navigationTitle("Project")
                .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 240)
        } detail: {
            NavigationStack {
                workspaceSurface(metrics: metrics, inset: 12, radius: 12, shadow: 6)
                    .navigationTitle(selectedPane == .screenplay ? project.metadata.title : selectedPane.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                splitVisibility = splitVisibility == .detailOnly ? .all : .detailOnly
                            } label: {
                                Image(systemName: "sidebar.left")
                            }
                        }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            if selectedPane == .screenplay {
                                Button(action: performSmartEnter) { Image(systemName: "return") }
                                Button(action: performFormatCycle) { Image(systemName: "textformat") }
                            }
                            Button(action: onClose) { Image(systemName: "folder") }
                        }
                    }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear { splitVisibility = .automatic }
    }

    private func regularPadWorkspace(metrics: IOSAdaptiveLayoutMetrics, isLandscape: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Button(action: onClose) { Image(systemName: "folder").frame(width: 38, height: 38) }
                Button { withAnimation { showsNavigator.toggle() } } label: {
                    Image(systemName: "sidebar.left").frame(width: 38, height: 38)
                }
                workspaceMenu
                Text(selectedPane == .screenplay ? project.metadata.title : selectedPane.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                if selectedPane == .screenplay {
                    Button(action: performSmartEnter) { Image(systemName: "return").frame(width: 38, height: 38) }
                    Button(action: performFormatCycle) { Image(systemName: "textformat").frame(width: 38, height: 38) }
                    Button { withAnimation { showsInspector.toggle() } } label: {
                        Image(systemName: "sidebar.right").frame(width: 38, height: 38)
                    }
                }
            }
            .padding(.horizontal, 6)
            .frame(height: isLandscape ? 42 : 46)
            .background(.bar)

            HStack(spacing: 0) {
                if showsNavigator {
                    projectNavigator(showInspectorSummary: true)
                        .frame(width: isLandscape ? 200 : 220)
                    Divider()
                }
                workspaceSurface(metrics: metrics, inset: isLandscape ? 10 : 16, radius: 12, shadow: 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if selectedPane == .screenplay, showsInspector {
                    Divider()
                    projectInspector.frame(width: isLandscape ? 220 : 240)
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }

    private var compactHeader: some View {
        HStack(spacing: 4) {
            Button(action: onClose) {
                Image(systemName: "chevron.backward").frame(width: 40, height: 40)
            }
            workspaceMenu.frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 0) {
                Text(selectedPane.title).font(.subheadline.weight(.semibold)).lineLimit(1)
                if selectedPane == .screenplay {
                    Text(project.metadata.title).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if selectedPane == .screenplay {
                Button(action: performSmartEnter) { Image(systemName: "return").frame(width: 40, height: 40) }
                Menu {
                    Button("Change Format", systemImage: "textformat", action: performFormatCycle)
                    Button("Dismiss Suggestions", systemImage: "xmark") { _ = dismissSuggestions() }
                } label: {
                    Image(systemName: "ellipsis.circle").frame(width: 40, height: 40)
                }
            }
        }
        .padding(.horizontal, 2)
    }

    private var workspaceMenu: some View {
        Menu {
            ForEach(IOSWorkspacePane.allCases) { pane in
                Button { selectPane(pane) } label: {
                    Label(pane.title, systemImage: pane.systemImage)
                }
            }
        } label: {
            Image(systemName: selectedPane.systemImage).frame(width: 38, height: 38)
        }
    }

    @ViewBuilder
    private func workspaceSurface(
        metrics: IOSAdaptiveLayoutMetrics,
        inset: CGFloat,
        radius: CGFloat,
        shadow: CGFloat
    ) -> some View {
        if selectedPane == .screenplay {
            editorCanvas(metrics: metrics, inset: inset, radius: radius, shadow: shadow)
        } else {
            IOSWorkspacePaneContent(
                pane: selectedPane,
                project: $project,
                commitProjectChange: commitWorkspaceProjectChange,
                openReviewFinding: openReviewFinding
            )
        }
    }

    private func editorCanvas(
        metrics: IOSAdaptiveLayoutMetrics,
        inset: CGFloat,
        radius: CGFloat,
        shadow: CGFloat
    ) -> some View {
        ZStack(alignment: .bottom) {
            Color(uiColor: .secondarySystemBackground)
            IOSNativeTextKitEditor(
                session: $session,
                formattingRange: formattingWindow.range,
                styleRuns: boundedStyleRuns,
                onVisibleRangeChanged: updateVisibleRange,
                onMoveSuggestion: moveSuggestion,
                onAcceptSuggestion: acceptSelectedSuggestion,
                onDismissSuggestions: dismissSuggestions,
                onSmartEnter: performSmartEnter,
                onFormatCycle: performFormatCycle
            )
            .frame(maxWidth: metrics.maximumReadableEditorWidth, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(shadow > 0 ? 0.10 : 0), radius: shadow, y: 2)
            .padding(inset)

            IOSAutocompletePanel(
                state: autocomplete,
                compact: metrics.autocompleteMode == .compactFloatingCard,
                accept: acceptSuggestion,
                dismiss: { _ = dismissSuggestions() }
            )
            .frame(maxWidth: metrics.autocompleteMaximumWidth)
            .padding(.horizontal, max(8, inset))
            .padding(.bottom, max(8, inset))
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .animation(.snappy(duration: 0.2), value: autocomplete.isPresented)
    }

    private func projectNavigator(showInspectorSummary: Bool) -> some View {
        List {
            Section("Workspace") {
                ForEach(IOSWorkspacePane.allCases) { pane in
                    Button { selectPane(pane) } label: {
                        HStack {
                            Label(pane.title, systemImage: pane.systemImage)
                            Spacer()
                            if selectedPane == pane { Image(systemName: "checkmark") }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            if showInspectorSummary {
                Section("Project") {
                    LabeledContent("Scenes", value: "\(project.screenplay.scenes.count)")
                    LabeledContent("Characters", value: "\(project.characters.count)")
                }
            }
        }
        .listStyle(.sidebar)
    }

    private var projectInspector: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Inspector").font(.headline)
                LabeledContent("Title", value: project.metadata.title)
                LabeledContent("Scenes", value: "\(project.screenplay.scenes.count)")
                LabeledContent("Characters", value: "\(project.characters.count)")
                Button("Smart Enter", action: performSmartEnter)
                Button("Change Format", action: performFormatCycle)
            }
            .padding(12)
        }
    }

    private var formattingWindow: IOSEditorFormattingWindow {
        IOSEditorFormattingPolicy.formattingWindow(visibleRange: visibleRange, text: session.text)
    }

    private var boundedStyleRuns: [EditorLineStyleRun] {
        IOSEditorFormattingPolicy.boundedStyleRuns(text: session.text, visibleRange: visibleRange)
    }

    private var workspacePolicy: IOSWorkspacePolicy {
        let deviceClass: IOSDeviceClass = UIDevice.current.userInterfaceIdiom == .pad
            ? (horizontalSizeClass == .compact ? .padCompact : .padRegular)
            : .phoneRegular
        return IOSWorkspacePolicy.policy(for: deviceClass)
    }

    private func selectPane(_ pane: IOSWorkspacePane) {
        selectedPane = pane
        if pane != .screenplay { autocomplete.dismiss() }
    }

    private func commitWorkspaceProjectChange(_ updated: DreamJotterProject) {
        guard updated != project else { return }
        project = updated
        projectMutationRevision &+= 1
    }

    private func openReviewFinding(_ finding: ReviewFinding) {
        selectedPane = .screenplay
        autocomplete.dismiss()
        if let range = finding.scriptRange {
            session.updateSelection(IOSEditorSelection(location: range.location, length: range.length))
            visibleRange = EditorTextRange(location: range.location, length: max(range.length, 1))
        }
    }

    private func updateVisibleRange(_ range: NSRange) {
        visibleRange = EditorTextRange(location: range.location, length: range.length)
    }

    private func refreshAutocomplete() {
        autocomplete.replaceSuggestions(IOSAutocompleteService.suggestions(
            text: session.text,
            cursorLocation: session.selection.location,
            characters: project.characters.map(\.displayName),
            scenes: project.screenplay.scenes,
            language: ScreenplayLanguagePersistence.language(in: project)
        ))
    }

    private func moveSuggestion(_ offset: Int) -> Bool { autocomplete.moveSelection(by: offset) }

    private func acceptSelectedSuggestion() -> Bool {
        guard let suggestion = autocomplete.selectedSuggestion else { return false }
        acceptSuggestion(suggestion)
        return true
    }

    private func acceptSuggestion(_ suggestion: EditorSuggestion) {
        IOSEditorCommandService.acceptSuggestion(suggestion, session: &session)
        autocomplete.dismiss()
    }

    private func dismissSuggestions() -> Bool {
        guard autocomplete.isPresented else { return false }
        autocomplete.dismiss()
        return true
    }

    private func performSmartEnter() {
        IOSEditorCommandService.performSmartEnter(session: &session)
        autocomplete.dismiss()
    }

    private func performFormatCycle() {
        IOSEditorCommandService.cycleCurrentElementKind(session: &session)
        autocomplete.dismiss()
    }

    private func parseCurrentRevision() async {
        let revision = session.revision
        try? await Task.sleep(for: .milliseconds(workspacePolicy.parseDebounceMilliseconds))
        guard !Task.isCancelled, revision == session.revision else { return }
        project = IOSEditorProjectProjection.applying(text: session.text, to: project)
        session.markParseCompleted(revision: revision)
    }

    private func autosaveCurrentRevision() async {
        guard let revision = session.autosaveRevisionPending else { return }
        try? await Task.sleep(for: .milliseconds(workspacePolicy.autosaveDebounceMilliseconds))
        guard !Task.isCancelled, revision == session.revision else { return }
        await save(revision: revision)
    }

    private func saveWorkspaceProjectMutation() async {
        do {
            let projected = IOSEditorProjectProjection.applying(text: session.text, to: project)
            let snapshot = try await documentAdapter.saveProject(
                projected,
                at: packageURL,
                expectedGeneration: generation
            )
            project = snapshot.project
            generation = snapshot.generation
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveImmediatelyForLifecycleTransition() async {
        if let revision = session.autosaveRevisionPending {
            await save(revision: revision)
        } else if projectMutationRevision > 0 {
            await saveWorkspaceProjectMutation()
        }
    }

    private func save(revision: IOSEditorRevision) async {
        do {
            let projected = IOSEditorProjectProjection.applying(text: session.text, to: project)
            let snapshot = try await documentAdapter.saveProject(
                projected,
                at: packageURL,
                expectedGeneration: generation
            )
            project = snapshot.project
            generation = snapshot.generation
            session.markSaveCompleted(revision: revision)
        } catch {
            session.markSaveFailed(revision: revision)
            errorMessage = error.localizedDescription
        }
    }
}
