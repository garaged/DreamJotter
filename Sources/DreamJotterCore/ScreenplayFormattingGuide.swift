import Foundation

public struct ScreenplayFormattingGuideEntry: Equatable, Sendable, Identifiable {
    public let type: ScreenplayParagraphType
    public let marker: String
    public let example: String
    public let guidance: String
    public let howToUse: String

    public var id: ScreenplayParagraphType { type }

    public init(
        type: ScreenplayParagraphType,
        marker: String,
        example: String,
        guidance: String,
        howToUse: String
    ) {
        self.type = type
        self.marker = marker
        self.example = example
        self.guidance = guidance
        self.howToUse = howToUse
    }
}

public enum ScreenplayFormattingGuide {
    public static let entries: [ScreenplayFormattingGuideEntry] = [
        .init(
            type: .sceneHeading,
            marker: ".",
            example: ". INT. KITCHEN - NIGHT",
            guidance: "Starts a new scene and identifies interior or exterior, location, and time of day.",
            howToUse: "Use one at every change of place or time. A typical heading is INT. or EXT., followed by the location, then a dash and time of day. Example: INT. KITCHEN - NIGHT."
        ),
        .init(
            type: .action,
            marker: "!",
            example: "! Rain hits the windows.",
            guidance: "Full-width description of what the audience can see or hear.",
            howToUse: "Use present tense for visible or audible events. Do not put a character's spoken words here. Select Action explicitly when ordinary prose is being mistaken for Dialogue."
        ),
        .init(
            type: .characterIntroduction,
            marker: "+",
            example: "+ SOFÍA, 30s, enters.",
            guidance: "Introduces a character for the first time while retaining action formatting.",
            howToUse: "Use this only for a character's first meaningful appearance. Capitalize the name and add only essential identifying details; later appearances should normally be Action."
        ),
        .init(
            type: .characterCue,
            marker: "@",
            example: "@SOFÍA / TOM",
            guidance: "Names who speaks in the dialogue block that follows.",
            howToUse: "Put the speaker name immediately before Dialogue. For simultaneous or shared dialogue, combine names with a slash, such as SOFÍA / TOM. A blank line ends the dialogue block."
        ),
        .init(
            type: .dialogue,
            marker: ":",
            example: ": We should leave now.",
            guidance: "Spoken words rendered in the screenplay dialogue column.",
            howToUse: "Use after a Character Cue. Keep only words the character says here; movement and visible behavior belong in Action, while a brief delivery note belongs in a Parenthetical."
        ),
        .init(
            type: .parenthetical,
            marker: "( )",
            example: "(quietly)",
            guidance: "A short performance or delivery direction inside a dialogue block.",
            howToUse: "Use sparingly and keep it brief, such as (whispering) or (to Tom). Do not use it for long action, camera direction, or information the actor cannot perform."
        ),
        .init(
            type: .transition,
            marker: ">",
            example: "> CUT TO:",
            guidance: "A right-aligned editorial transition between scenes or sequences.",
            howToUse: "Use only when the transition itself matters, such as CUT TO:, MATCH CUT TO:, or FADE OUT. Most scene changes need no written transition."
        ),
        .init(
            type: .shot,
            marker: "!!",
            example: "!! CLOSE ON: THE KEY",
            guidance: "A deliberate camera framing or shot instruction.",
            howToUse: "Use when a specific image or framing is essential to understanding the scene. Avoid directing every camera angle; ordinary visual events should be written as Action."
        ),
        .init(
            type: .section,
            marker: "#",
            example: "# ACT TWO",
            guidance: "An organizational heading for the writer's structure.",
            howToUse: "Use for acts, sequences, or planning groups. Sections help organize the project but are not normal screenplay content and may be omitted from production exports."
        ),
        .init(
            type: .synopsis,
            marker: "=",
            example: "= The search moves downtown.",
            guidance: "A planning summary of what happens in a scene or section.",
            howToUse: "Use for outline-level summaries rather than finished screenplay prose. A Synopsis describes the story for the writer; Action describes what the audience experiences on screen."
        ),
        .init(
            type: .montage,
            marker: "%%",
            example: "%% MONTAGE - SEARCHING THE CITY",
            guidance: "Marks a compressed sequence of related visual beats.",
            howToUse: "Use when several short actions collectively show time passing or progress. Follow it with concise visual beats, and return to normal Scene Heading and Action formatting afterward."
        ),
        .init(
            type: .note,
            marker: "[[ ]]",
            example: "[[Tighten this scene]]",
            guidance: "A private writing or revision note that is not screenplay content.",
            howToUse: "Use for reminders, questions, and revision tasks. Notes are for the writer and can be excluded from exports; do not use them for information the reader must see in the screenplay."
        ),
        .init(
            type: .pageBreak,
            marker: "===",
            example: "===",
            guidance: "Forces the next screenplay element to begin on a new page.",
            howToUse: "Use rarely, only when a deliberate production or presentation break is required. Normal screenplay pagination should be left to the PDF layout engine."
        )
    ]

    public static func entry(for type: ScreenplayParagraphType) -> ScreenplayFormattingGuideEntry? {
        entries.first { $0.type == type }
    }
}
