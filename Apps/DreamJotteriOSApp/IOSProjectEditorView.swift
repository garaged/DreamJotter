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

    private let packageURL: URL
    private let onClose: () -> Void
    private let documentAdapter = IOSProjectDocumentAdapter()

    init(
        snapshot: IOSProjectDocumentSnapshot,
        onClose: @escaping () -> Void = {}
    ) {
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

            layout(for: metrics)
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
        .onChange(of: session.selection) { _, _ in
            refreshAutocomplete()
        }
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
    private func layout(for metrics: IOSAdaptiveLayoutMetrics) -> some View {
        switch metrics.layoutClass {
        case .compactPhone:
            compactPhoneWorkspace(metrics: metrics)
        case .regularPhone:
            regularPhoneWorkspace(metrics: metrics)
        case .compactPad:
            compactPadWorkspace(metrics: metrics)
        case .regularPad:
            regularPadWorkspace(metrics: metrics)
        }
    }

    private func compactPhoneWorkspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button(action: onClose) {
                    Image(systemName: "chevron.backward")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Documents")

                Text(project.metadata.title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("Project: \(project.metadata.title)")

                Menu {
                    Button("Smart Enter", systemImage: "return", action: performSmartEnter)
                    Button("Change Format", systemImage: "textformat", action: performFormatCycle)
                    Button("Dismiss Suggestions", systemImage: "xmark") {
                        _ = dismissSuggestions()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Editing commands")
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(.bar)

            editorCanvas(
                metrics: metrics,
                cornerRadius: 0,
                horizontalPadding: 0,
                verticalPadding: 0,
                shadowRadius: 0
            )
        }
        .background(Color(uiColor: .systemBackground))
    }

    private func regularPhoneWorkspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        NavigationStack {
            editorCanvas(
                metrics: metrics,
                cornerRadius: 12,
                horizontalPadding: 12,
                verticalPadding: 10,
                shadowRadius: 4
            )
            .navigationTitle(project.metadata.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Label("Documents", systemImage: "chevron.backward")
                            .labelStyle(.iconOnly)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: performSmartEnter) {
                        Image(systemName: "return")
                    }
                    .accessibilityLabel("Smart Enter")

                    Button(action: performFormatCycle) {
                        Image(systemName: "textformat")
                    }
                    .accessibilityLabel("Change screenplay element format")
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 14) {
                    Label("Writing", systemImage: "square.and.pencil")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Button("Smart Enter", action: performSmartEnter)
                        .buttonStyle(.borderless)
                    Button("Format", action: performFormatCycle)
                        .buttonStyle(.borderless)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(.bar)
            }
        }
    }

    private func compactPadWorkspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        NavigationSplitView(columnVisibility: $splitVisibility) {
            projectNavigator(showInspectorSummary: false)
                .navigationTitle("Project")
                .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)
        } detail: {
            NavigationStack {
                editorCanvas(
                    metrics: metrics,
                    cornerRadius: 14,
                    horizontalPadding: 24,
                    verticalPadding: 18,
                    shadowRadius: 8
                )
                .navigationTitle(project.metadata.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Documents", systemImage: "folder", action: onClose)
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Smart Enter", systemImage: "return", action: performSmartEnter)
                        Button("Format", systemImage: "textformat", action: performFormatCycle)
                    }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear { splitVisibility = .automatic }
    }

    private func regularPadWorkspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button("Documents", systemImage: "folder", action: onClose)
                Divider().frame(height: 24)
                VStack(alignment: .leading, spacing: 1) {
                    Text(project.metadata.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Screenplay Studio")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Smart Enter", systemImage: "return", action: performSmartEnter)
                    .buttonStyle(.bordered)
                Button("Format", systemImage: "textformat", action: performFormatCycle)
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 18)
            .frame(height: 58)
            .background(.bar)

            HStack(spacing: 0) {
                projectNavigator(showInspectorSummary: true)
                    .frame(width: 270)
                    .background(Color(uiColor: .secondarySystemBackground))

                Divider()

                editorCanvas(
                    metrics: metrics,
                    cornerRadius: 16,
                    horizontalPadding: 36,
                    verticalPadding: 24,
                    shadowRadius: 12
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                projectInspector
                    .frame(width: 290)
                    .background(Color(uiColor: .secondarySystemBackground))
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
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
                    .accessibilityLabel("Current project: \(project.metadata.title)")
            }

            Section("Workspace") {
                Label("Screenplay", systemImage: "text.alignleft")
                    .fontWeight(.semibold)
                Label("Scenes", systemImage: "rectangle.stack")
                Label("Characters", systemImage: "person.2")
                Label("Locations", systemImage: "mappin.and.ellipse")
                Label("Notes", systemImage: "note.text")
                Label("Review", systemImage: "checkmark.circle")
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
            VStack(alignment: .leading, spacing: 18) {
                Text("Inspector")
                    .font(.title3.weight(.semibold))

                GroupBox("Current document") {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("Title", value: project.metadata.title)
                        LabeledContent("Scenes", value: "\(project.screenplay.scenes.count)")
                        LabeledContent("Characters", value: "\(project.characters.count)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Editing") {
                    VStack(spacing: 10) {
                        Button("Smart Enter", systemImage: "return", action: performSmartEnter)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button("Change Format", systemImage: "textformat", action: performFormatCycle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(18)
        }
    }

    private var formattingWindow: IOSEditorFormattingWindow {
        IOSEditorFormattingPolicy.formattingWindow(
            visibleRange: visibleRange,
            text: session.text
        )
    }

    private var boundedStyleRuns: [EditorLineStyleRun] {
        IOSEditorFormattingPolicy.boundedStyleRuns(
            text: session.text,
            visibleRange: visibleRange
        )
    }

    private var workspacePolicy: IOSWorkspacePolicy {
        let deviceClass: IOSDeviceClass
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceClass = horizontalSizeClass == .compact ? .padCompact : .padRegular
        } else {
            deviceClass = .phoneRegular
        }
        return IOSWorkspacePolicy.policy(for: deviceClass)
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

    private func moveSuggestion(_ offset: Int) -> Bool {
        autocomplete.moveSelection(by: offset)
    }

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
