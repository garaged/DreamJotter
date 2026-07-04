import Foundation

public struct ScreenplayFormattingGuideEntry: Equatable, Sendable, Identifiable {
    public let type: ScreenplayParagraphType
    public let marker: String
    public let example: String
    public let guidance: String

    public var id: ScreenplayParagraphType { type }

    public init(
        type: ScreenplayParagraphType,
        marker: String,
        example: String,
        guidance: String
    ) {
        self.type = type
        self.marker = marker
        self.example = example
        self.guidance = guidance
    }
}

public enum ScreenplayFormattingGuide {
    public static let entries: [ScreenplayFormattingGuideEntry] = [
        .init(type: .sceneHeading, marker: ".", example: ". INT. KITCHEN - NIGHT", guidance: "Starts a scene. DreamJotter also recognizes common INT./EXT. headings without the marker."),
        .init(type: .action, marker: "!", example: "! Rain hits the windows.", guidance: "Full-width visual description. Use this when automatic inference is ambiguous."),
        .init(type: .characterIntroduction, marker: "+", example: "+ SOFÍA, 30s, enters.", guidance: "A character introduction rendered at action width."),
        .init(type: .characterCue, marker: "@", example: "@SOFÍA", guidance: "Names the speaker. The following contiguous parenthetical/dialogue lines form one dialogue block."),
        .init(type: .dialogue, marker: ":", example: ": We should leave now.", guidance: "Spoken text in the dialogue column. A blank line ends the dialogue block."),
        .init(type: .parenthetical, marker: "( )", example: "(quietly)", guidance: "A short performance direction inside a dialogue block."),
        .init(type: .transition, marker: ">", example: "> CUT TO:", guidance: "A right-aligned editorial transition."),
        .init(type: .shot, marker: "!!", example: "!! CLOSE ON: THE KEY", guidance: "A camera or shot instruction."),
        .init(type: .section, marker: "#", example: "# ACT TWO", guidance: "A structural section used for organization."),
        .init(type: .synopsis, marker: "=", example: "= The search moves downtown.", guidance: "A non-screenplay summary paragraph."),
        .init(type: .montage, marker: "%%", example: "%% MONTAGE - SEARCHING THE CITY", guidance: "A montage heading or structural montage description."),
        .init(type: .note, marker: "[[ ]]", example: "[[Tighten this scene]]", guidance: "An internal writing note. Notes may be excluded by export presets."),
        .init(type: .pageBreak, marker: "===", example: "===", guidance: "Forces the next screenplay element onto a new page.")
    ]

    public static func entry(for type: ScreenplayParagraphType) -> ScreenplayFormattingGuideEntry? {
        entries.first { $0.type == type }
    }
}
