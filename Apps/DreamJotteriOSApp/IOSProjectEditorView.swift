import DreamJotterCore
import DreamJotteriOS
import SwiftUI

struct IOSProjectEditorView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    @State private var project: DreamJotterProject
    @State private var generation: IOSPackageGeneration
    @State private var session: IOSEditorSession
    @State private var visibleRange = EditorTextRange(location: 0, length: 0)
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
            IOSNativeTextKitEditor(
                session: $session,
                onVisibleRangeChanged: { range in
                    visibleRange = EditorTextRange(
                        location: range.location,
                        length: range.length
                    )
                    _ = IOSEditorFormattingPolicy.boundedStyleRuns(
                        text: session.text,
                        visibleRange: visibleRange
                    )
                }
            )
            .navigationTitle(project.metadata.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Documents") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Smart Enter") {
                        IOSEditorCommandService.performSmartEnter(session: &session)
                    }
                    Button("Format") {
                        IOSEditorCommandService.cycleCurrentElementKind(session: &session)
                    }
                }
            }
        }
        .task(id: session.revision.value) {
            await parseCurrentRevision()
        }
        .task(id: session.autosaveRevisionPending?.value) {
            await autosaveCurrentRevision()
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
