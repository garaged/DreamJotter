import DreamJotterCore
import DreamJotteriOS
import Foundation
import Testing

@Suite("iOS editor project projection")
struct IOSEditorProjectProjectionTests {
    @Test("text projection updates screenplay while preserving project-owned data")
    func projectionPreservesProjectData() {
        let createdAt = Date(timeIntervalSince1970: 100)
        let modifiedAt = Date(timeIntervalSince1970: 200)
        let original = ProjectFactory.createBlankProject(
            title: "Projection",
            projectID: "project-projection",
            screenplayID: "screenplay-projection",
            createdAt: createdAt
        )

        let updated = IOSEditorProjectProjection.applying(
            text: "INT. ROOM - DAY\n\nA quiet room.",
            to: original,
            modifiedAt: modifiedAt
        )

        #expect(updated.metadata.id == original.metadata.id)
        #expect(updated.metadata.title == original.metadata.title)
        #expect(updated.metadata.createdAt == original.metadata.createdAt)
        #expect(updated.metadata.modifiedAt == modifiedAt)
        #expect(updated.characters == original.characters)
        #expect(updated.locations == original.locations)
        #expect(updated.notes == original.notes)
        #expect(updated.screenplay.scenes.count == 1)
    }
}
