import DreamJotterCore

extension ProjectDocumentViewModel {
    var localizedScriptTodoNotes: [ProjectNote] {
        LocalizedNotesProjection.unresolvedScriptTodos(
            in: project,
            now: project.metadata.modifiedAt
        )
    }
}
