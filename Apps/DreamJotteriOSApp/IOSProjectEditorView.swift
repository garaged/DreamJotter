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
    @State private var errorMessage: String?
    @State private var splitVisibility: NavigationSplitViewVisibility = .all
    @State private var showsNavigator = true
    @State private var showsInspector = true
    @State private var selectedPane: IOSWorkspacePane = .screenplay

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
            let isLandscape = proxy.size.width > proxy.size.height

            layout(for: metrics, isLandscape: isLandscape)
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
            compactEditorHeader
                .frame(height: 44)
                .background(.bar)
            workspaceSurface(metrics: metrics, cornerRadius: 0, horizontalPadding: 0, verticalPadding: 0, shadowRadius: 0)
        }
    }

    private func regularPhoneWorkspace(metrics: IOSAdaptiveLayoutMetrics, isLandscape: Bool) -> some View {
        Group {
            if isLandscape {
                VStack(spacing: 0) {
                    compactEditorHeader
                        .frame(height: 40)
                        .background(.bar)
                    workspaceSurface(metrics: metrics, cornerRadius: 0, horizontalPadding: 0, verticalPadding: 0, shadowRadius: 0)
                }
            } else {
                NavigationStack {
                    workspaceSurface(metrics: metrics, cornerRadius: 10, horizontalPadding: 8, verticalPadding: 6, shadowRadius: 3)
                        .navigationTitle(selectedPane == .screenplay ? project.metadata.title : selectedPane.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                HStack(spacing: 2) {
                                    Button(action: onClose) { Image(systemName: "chevron.backward") }
                                        .accessibilityLabel("Documents")
                                    workspaceMenu
                                }
                            }
                            if selectedPane == .screenplay {
                                ToolbarItemGroup(placement: .topBarTrailing) {
                                    Button(action: performSmartEnter) { Image(systemName: "return") }
                                        .accessibilityLabel("Smart Enter")
                                    Button(action: performFormatCycle) { Image(systemName: "textformat") }
                                        .accessibilityLabel("Change screenplay element format")
                                }
                            }
                        }
                }
            }
        }
    }

    private var compactEditorHeader: some View {
        HStack(spacing: 4) {
            Button(action: onClose) {
                Image(systemName: "chevron.backward")
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("Documents")

            workspaceMenu.frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 0) {
                Text(selectedPane.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                if selectedPane == .screenplay {
                    Text(project.metadata.title)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if selectedPane == .screenplay {
                Button(action: performSmartEnter) {
                    Image(systemName: "return").frame(width: 40, height: 40)
                }
                .accessibilityLabel("Smart Enter")

                Menu {
                    Button("Change Format", systemImage: "textformat", action: performFormatCycle)
                    Button("Dismiss Suggestions", systemImage: "xmark") { _ = dismissSuggestions() }
                } label: {
                    Image(systemName: "ellipsis.circle").frame(width: 40, height: 40)
                }
                .accessibilityLabel("Editing commands")
            }
        }
        .padding(.horizontal, 2)
    }

    private var workspaceMenu: some View {
        Menu {
            ForEach(IOSWorkspacePane.allCases) { pane in
                Button {
                    selectPane(pane)
                } label: {
                    Label(pane.title, systemImage: pane.systemImage)
                }
            }
        } label: {
            Image(systemName: selectedPane.systemImage)
                .frame(width: 38, height: 38)
        }
        .accessibilityLabel("Workspace: \(selectedPane.title)")
    }

    private func compactPadWorkspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        NavigationSplitView(columnVisibility: $splitVisibility) {
            projectNavigator(showInspectorSummary: false)
                .navigationTitle("Project")
                .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 240)
        } detail: {
            NavigationStack {
                workspaceSurface(metrics: metrics, cornerRadius: 12, horizontalPadding: 14, verticalPadding: 10, shadowRadius: 6)
                    .navigationTitle(selectedPane == .screenplay ? project.metadata.title : selectedPane.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                splitVisibility = splitVisibility == .detailOnly ? .all : .detailOnly
                            } label: {
                                Image(systemName: "sidebar.left")
                            }
                            .accessibilityLabel("Toggle project navigator")
                        }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            if selectedPane == .screenplay {
                                Button(action: performSmartEnter) { Image(systemName: "return") }
                                    .accessibilityLabel("Smart Enter")
                                Button(action: performFormatCycle) { Image(systemName: "textformat") }
                                    .accessibilityLabel("Change format")
                            }
                            Button(action: onClose) { Image(systemName: "folder") }
                                .accessibilityLabel("Documents")
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
                    .accessibilityLabel("Documents")

                Button {
                    withAnimation(.snappy(duration: 0.18)) { showsNavigator.toggle() }
                } label: {
                    Image(systemName: "sidebar.left").frame(width: 38, height: 38)
                }
                .accessibilityLabel(showsNavigator ? "Hide project navigator" : "Show project navigator")

                workspaceMenu

                Text(selectedPane == .screenplay ? project.metadata.title : selectedPane.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Spacer()

                if selectedPane == .screenplay {
                    Button(action: performSmartEnter) { Image(systemName: "return").frame(width: 38, height: 38) }
                        .accessibilityLabel("Smart Enter")
                    Button(action: performFormatCycle) { Image(systemName: "textformat").frame(width: 38, height: 38) }
                        .accessibilityLabel("Change format")
                    Button {
                        withAnimation(.snappy(duration: 0.18)) { showsInspector.toggle() }
                    } label: {
                        Image(systemName: "sidebar.right").frame(width: 38, height: 38)
                    }
                    .accessibilityLabel(showsInspector ? "Hide inspector" : "Show inspector")
                }
            }
            .padding(.horizontal, 6)
            .frame(height: isLandscape ? 42 : 46)
            .background(.bar)

            HStack(spacing: 0) {
                if showsNavigator {
                    projectNavigator(showInspectorSummary: true)
                        .frame(width: isLandscape ? 200 : 220)
                        .background(Color(uiColor: .secondarySystemBackground))
                    Divider()
                }

                workspaceSurface(
                    metrics: metrics,
                    cornerRadius: 12,
                    horizontalPadding: isLandscape ? 12 : 18,
                    verticalPadding: isLandscape ? 8 : 14,
                    shadowRadius: 8
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if selectedPane == .screenplay, showsInspector {
                    Divider()
                    projectInspector
                        .frame(width: isLandscape ? 220 : 240)
                        .background(Color(uiColor: .secondarySystemBackground))
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }

    @ViewBuilder
    private func workspaceSurface(
        metrics: IOSAdaptiveLayoutMetrics,
        cornerRadius: CGFloat,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        shadowRadius: CGFloat
    ) -> some View {
        if selectedPane == .screenplay {
            editorCanvas(
                metrics: metrics,
                cornerRadius: cornerRadius,
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
                shadowRadius: shadowRadius
            )
        } else {
            IOSWorkspacePaneContent(pane: selectedPane, project: project)
        }
    }

    private func editorCanvas(
        metrics: IOSAdaptiveLayoutMetrics,
        cornerRadius: CGFloat,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        shadowRadius: CGFloat
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
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(shadowRadius > 0 ? 0.10 : 0), radius: shadowRadius, y: 2)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)

            IOSAutocompletePanel(
                state: autocomplete,
                compact: metrics.autocompleteMode == .compactFloatingCard,
                accept: acceptSuggestion,
                dismiss: { _ = dismissSuggestions() }
            )
            .frame(maxWidth: metrics.autocompleteMaximumWidth)
            .padding(.horizontal, max(8, horizontalPadding))
            .padding(.bottom, max(8, verticalPadding))
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
        .animation(.snappy(duration: 0.2), value: autocomplete.isPresented)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Screenplay editor for \(project.metadata.title)")
    }

    private func projectNavigator(showInspectorSummary: Bool) -> some View {
        List {
            Section {
                Label(project.metadata.title, systemImage: "doc.text")
                    .font(.headline)
                    .lineLimit(2)
            }

            Section("Workspace") {
                ForEach(IOSWorkspacePane.allCases) { pane in
                    Button {
                        selectPane(pane)
                    } label: {
                        HStack {
                            Label(pane.title, systemImage: pane.systemImage)
                            Spacer()
                            if selectedPane == pane {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
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
            VStack(alignment: .leading, spacing: 14) {
                Text("Inspector").font(.headline)
                GroupBox("Current document") {
                    VStack(alignment: .leading, spacing: 6) {
                        LabeledContent("Title", value: project.metadata.title)
                        LabeledContent("Scenes", value: "\(project.screenplay.scenes.count)")
                        LabeledContent("Characters", value: "\(project.characters.count)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                GroupBox("Editing") {
                    VStack(spacing: 8) {
                        Button("Smart Enter", systemImage: "return", action: performSmartEnter)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button("Change Format", systemImage: "textformat", action: performFormatCycle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
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

    private func saveImmediatelyForLifecycleTransition() async {
        guard let revision = session.autosaveRevisionPending else { return }
        await save(revision: revision)
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
