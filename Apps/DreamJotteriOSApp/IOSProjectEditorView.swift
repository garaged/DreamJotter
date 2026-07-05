import DreamJotterCore
import DreamJotteriOS
import SwiftUI
import UIKit

struct IOSProjectEditorView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var project: DreamJotterProject
    @State private var generation: IOSPackageGeneration
    @State private var session: IOSEditorSession
    @State private var visibleRange = EditorTextRange(location: 0, length: 0)
    @State private var autocomplete = IOSAutocompleteState()
    @State private var errorMessage: String?
    @State private var splitVisibility: NavigationSplitViewVisibility = .all

    private let packageURL: URL
    private let documentAdapter = IOSProjectDocumentAdapter()

    init(snapshot: IOSProjectDocumentSnapshot) {
        packageURL = snapshot.packageURL
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
            workspace(metrics: metrics)
        }
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
    private func workspace(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        switch metrics.navigationMode {
        case .singlePane:
            NavigationStack {
                editorSurface(metrics: metrics)
                    .navigationTitle(project.metadata.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { editorToolbar(metrics: metrics) }
            }
        case .collapsibleSplit, .persistentSplit:
            NavigationSplitView(columnVisibility: $splitVisibility) {
                projectSidebar(metrics: metrics)
                    .navigationTitle("Project")
                    .navigationSplitViewColumnWidth(
                        min: 220,
                        ideal: metrics.preferredSidebarWidth,
                        max: 340
                    )
            } detail: {
                NavigationStack {
                    editorSurface(metrics: metrics)
                        .navigationTitle(project.metadata.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { editorToolbar(metrics: metrics) }
                }
            }
            .navigationSplitViewStyle(.balanced)
            .onAppear {
                splitVisibility = metrics.navigationMode == .persistentSplit ? .all : .automatic
            }
        }
    }

    private func editorSurface(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        ZStack(alignment: .bottom) {
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea()

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
            .frame(maxWidth: metrics.maximumReadableEditorWidth)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: metrics.layoutClass == .regularPad ? 12 : 0))
            .shadow(
                color: metrics.layoutClass == .regularPad ? .black.opacity(0.08) : .clear,
                radius: 10,
                y: 2
            )
            .padding(.horizontal, metrics.horizontalEditorInset)

            IOSAutocompletePanel(
                state: autocomplete,
                compact: metrics.autocompleteMode == .compactFloatingCard,
                accept: acceptSuggestion,
                dismiss: { _ = dismissSuggestions() }
            )
            .frame(maxWidth: metrics.autocompleteMaximumWidth)
            .padding(.horizontal, max(8, metrics.horizontalEditorInset))
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .animation(.snappy(duration: 0.2), value: autocomplete.isPresented)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Screenplay editor for \(project.metadata.title)")
    }

    private func projectSidebar(metrics: IOSAdaptiveLayoutMetrics) -> some View {
        List {
            Section {
                Label(project.metadata.title, systemImage: "doc.text")
                    .font(.headline)
                    .lineLimit(2)
                    .accessibilityLabel("Current project: \(project.metadata.title)")
            }

            Section("Workspace") {
                Label("Screenplay", systemImage: "text.alignleft")
                    .foregroundStyle(.primary)
                Label("Scenes", systemImage: "rectangle.stack")
                    .foregroundStyle(.secondary)
                Label("Characters", systemImage: "person.2")
                    .foregroundStyle(.secondary)
                Label("Notes", systemImage: "note.text")
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    dismiss()
                } label: {
                    Label("Documents", systemImage: "folder")
                }
            }
        }
        .listStyle(.sidebar)
    }

    @ToolbarContentBuilder
    private func editorToolbar(metrics: IOSAdaptiveLayoutMetrics) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Label("Documents", systemImage: "chevron.backward")
                    .labelStyle(metrics.showsCommandLabels ? .titleAndIcon : .iconOnly)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityHint("Returns to the document browser")
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button(action: performSmartEnter) {
                Label("Smart Enter", systemImage: "return")
                    .labelStyle(metrics.showsCommandLabels ? .titleAndIcon : .iconOnly)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityHint("Creates the next appropriate screenplay element")

            Button(action: performFormatCycle) {
                Label("Format", systemImage: "textformat")
                    .labelStyle(metrics.showsCommandLabels ? .titleAndIcon : .iconOnly)
            }
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityHint("Changes the current screenplay element type")
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
