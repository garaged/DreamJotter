import Foundation

public enum FinalDraftExport {
    public static func xml(for project: DreamJotterProject) -> String {
        xml(for: project.screenplay, title: project.metadata.title)
    }

    public static func xml(
        for document: ScreenplayDocument,
        title: String = "Untitled"
    ) -> String {
        let paragraphs = document.elements.map(paragraphXML).joined(separator: "\n")
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <FinalDraft DocumentType="Script" Template="No" Version="1">
          <Content>
        \(paragraphs)
          </Content>
          <TitlePage>
            <Content>
              <Paragraph Type="Title"><Text>\(escape(title))</Text></Paragraph>
            </Content>
          </TitlePage>
        </FinalDraft>
        """
    }

    public static func data(for project: DreamJotterProject) -> Data {
        Data(xml(for: project).utf8)
    }

    private static func paragraphXML(_ element: ScriptElement) -> String {
        let type = paragraphType(for: element.kind)
        return "    <Paragraph Type=\"\(type)\"><Text>\(escape(element.text))</Text></Paragraph>"
    }

    private static func paragraphType(for kind: ScriptElementKind) -> String {
        switch kind {
        case .sceneHeading: "Scene Heading"
        case .action: "Action"
        case .characterCue: "Character"
        case .parenthetical: "Parenthetical"
        case .dialogue: "Dialogue"
        case .transition: "Transition"
        case .shot: "Shot"
        case .titlePage: "Title"
        case .section, .synopsis, .noteReference, .pageBreak, .unknown: "General"
        }
    }

    private static func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
