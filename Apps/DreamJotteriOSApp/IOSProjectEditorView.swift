import DreamJotterCore
import DreamJotteriOS
import SwiftUI

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

    private let packageURL: URL
    private let documentAdapter = IOSProjectDocumentAdapter()
    private let workspacePolicy = IOSWorkspacePolicy.policy(for: .phoneRegular)

    init(snapshot: IOSProjectDocumentSnapshot) {
        packageURL = snapshot.packageURL
        _project = State(initialValue: snapshot.project)
        _generation = State(initialValue: snapshot.generation)
        _session = State(initialValue: IOSEditorSession(
            text: FountainIO.exportScreenplay(snapshot.project.screenplay)
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
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

                IOSAutocompletePanel(
                    state: autocomplete,
                    compact: horizontalSizeClass == .compact,
                    accept: acceptSuggestion,
                    dismiss: { _ = dismissSuggestions() }
                )
                .padding(.horizontal, horizontalSizeClass == .compact ? 8 : 16)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .animation(.snappy(duration: 0.2), value: autocomplete.isPresented)
            .navigationTitle(project.metadata.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Documents", systemImage: "chevron.backward")
                    }
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
