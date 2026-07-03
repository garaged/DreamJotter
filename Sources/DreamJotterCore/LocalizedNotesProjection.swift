import Foundation

public enum LocalizedNotesProjection {
    public static func detectedScriptTodos(
        in project: DreamJotterProject,
        now: Date
    ) -> [ProjectNote] {
        let profile = ScreenplayLanguagePersistence.language(in: project)
        return project.screenplay.elements.enumerated().compactMap { index, element in
            guard element.kind == .noteReference,
                  let body = todoBody(from: element.text, profile: profile) else {
                return nil
            }
            return ProjectNote(
                id: "script-todo-\(index + 1)",
                title: "Script TODO",
                body: body,
                status: .open,
                source: .parsedScriptTodo,
                links: [NoteLink(targetKind: .screenplayElement, targetID: "element-\(index + 1)")],
                createdAt: now,
                updatedAt: now
            )
        }
    }

    public static func unresolvedScriptTodos(
        in project: DreamJotterProject,
        now: Date
    ) -> [ProjectNote] {
        detectedScriptTodos(in: project, now: now).filter { $0.status == .open }
    }

    private static func todoBody(
        from text: String,
        profile: ScreenplayLanguageProfile
    ) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lexicon = ScreenplayLexiconCatalog.lexicon(for: profile)
        for token in lexicon.todoTokens.sorted(by: { $0.count > $1.count }) {
            let prefix = String(trimmed.prefix(token.count))
            if TextNormalization.key(for: prefix) == TextNormalization.key(for: token) {
                let body = String(trimmed.dropFirst(token.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                return body.isEmpty ? nil : body
            }
        }
        return nil
    }
}
