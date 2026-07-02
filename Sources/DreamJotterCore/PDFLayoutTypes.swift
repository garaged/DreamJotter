import Foundation

public struct PDFPageSize: Codable, Equatable, Sendable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    public static let usLetter = PDFPageSize(width: 612, height: 792)
}

public struct PDFPageMargins: Codable, Equatable, Sendable {
    public let top: Double
    public let bottom: Double
    public let left: Double
    public let right: Double

    public init(top: Double, bottom: Double, left: Double, right: Double) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }

    public static let screenplay = PDFPageMargins(top: 72, bottom: 72, left: 90, right: 72)
}

public struct PDFLayoutSettings: Codable, Equatable, Sendable {
    public let pageSize: PDFPageSize
    public let margins: PDFPageMargins
    public let lineHeight: Double
    public let charactersPerBodyLine: Int
    public let contentLinesPerPage: Int
    public let includeTitlePage: Bool
    public let includePageNumbers: Bool
    public let suppressIdentifyingMetadata: Bool

    public init(
        pageSize: PDFPageSize = .usLetter,
        margins: PDFPageMargins = .screenplay,
        lineHeight: Double = 12,
        charactersPerBodyLine: Int = 60,
        contentLinesPerPage: Int = 54,
        includeTitlePage: Bool = true,
        includePageNumbers: Bool = true,
        suppressIdentifyingMetadata: Bool = false
    ) {
        self.pageSize = pageSize
        self.margins = margins
        self.lineHeight = lineHeight
        self.charactersPerBodyLine = charactersPerBodyLine
        self.contentLinesPerPage = contentLinesPerPage
        self.includeTitlePage = includeTitlePage
        self.includePageNumbers = includePageNumbers
        self.suppressIdentifyingMetadata = suppressIdentifyingMetadata
    }

    public static func defaults(for preset: ExportPreset) -> PDFLayoutSettings {
        PDFLayoutSettings(
            includeTitlePage: true,
            includePageNumbers: preset.id == "print-script" || preset.id == "contest-submission",
            suppressIdentifyingMetadata: preset.id == "contest-submission" || !preset.includesInternalIDs
        )
    }
}

public enum PDFBlockRole: String, Codable, Equatable, Sendable {
    case title
    case sceneHeading
    case action
    case characterCue
    case parenthetical
    case dialogue
    case transition
    case fallback
    case pageNumber
}

public enum PDFTextAlignment: String, Codable, Equatable, Sendable {
    case left
    case centered
    case right
}

public struct PDFContentAddress: Codable, Equatable, Hashable, Sendable {
    public let documentPageNumber: Int
    public let screenplayPageNumber: Int?
    public let blockNumber: Int
    public let paragraphNumber: Int?
    public let lineNumber: Int
    public let sourceElementIndex: Int?

    public init(
        documentPageNumber: Int,
        screenplayPageNumber: Int?,
        blockNumber: Int,
        paragraphNumber: Int?,
        lineNumber: Int,
        sourceElementIndex: Int?
    ) {
        self.documentPageNumber = documentPageNumber
        self.screenplayPageNumber = screenplayPageNumber
        self.blockNumber = blockNumber
        self.paragraphNumber = paragraphNumber
        self.lineNumber = lineNumber
        self.sourceElementIndex = sourceElementIndex
    }
}

public struct PDFLinePlan: Codable, Equatable, Sendable {
    public let lineNumber: Int
    public let text: String
    public let role: PDFBlockRole
    public let alignment: PDFTextAlignment

    public init(lineNumber: Int, text: String, role: PDFBlockRole, alignment: PDFTextAlignment) {
        self.lineNumber = lineNumber
        self.text = text
        self.role = role
        self.alignment = alignment
    }
}

public struct PDFBlockPlan: Codable, Equatable, Sendable {
    public let blockNumber: Int
    public let paragraphNumber: Int?
    public let sourceElementIndex: Int?
    public let role: PDFBlockRole
    public let sourceElementKind: ScriptElementKind?
    public let lines: [PDFLinePlan]
    public let keepWithNext: Bool

    public init(
        blockNumber: Int,
        paragraphNumber: Int?,
        sourceElementIndex: Int?,
        role: PDFBlockRole,
        sourceElementKind: ScriptElementKind?,
        lines: [PDFLinePlan],
        keepWithNext: Bool = false
    ) {
        self.blockNumber = blockNumber
        self.paragraphNumber = paragraphNumber
        self.sourceElementIndex = sourceElementIndex
        self.role = role
        self.sourceElementKind = sourceElementKind
        self.lines = lines
        self.keepWithNext = keepWithNext
    }

    public var lineCount: Int {
        lines.count
    }
}

public struct PDFPagePlan: Codable, Equatable, Sendable {
    public let pageIndex: Int
    public let documentPageNumber: Int
    public let screenplayPageNumber: Int?
    public let isTitlePage: Bool
    public let blocks: [PDFBlockPlan]

    public init(
        pageIndex: Int,
        documentPageNumber: Int,
        screenplayPageNumber: Int?,
        isTitlePage: Bool,
        blocks: [PDFBlockPlan]
    ) {
        self.pageIndex = pageIndex
        self.documentPageNumber = documentPageNumber
        self.screenplayPageNumber = screenplayPageNumber
        self.isTitlePage = isTitlePage
        self.blocks = blocks
    }
}

public enum PDFLayoutWarningCode: String, Codable, Equatable, Sendable {
    case notesOmitted
    case malformedElementFallback
    case missingTitleMetadata
}

public struct PDFLayoutWarning: Codable, Equatable, Sendable {
    public let code: PDFLayoutWarningCode
    public let message: String

    public init(code: PDFLayoutWarningCode, message: String) {
        self.code = code
        self.message = message
    }
}

public struct PDFLayoutPlan: Codable, Equatable, Sendable {
    public let documentTitle: String
    public let settings: PDFLayoutSettings
    public let pages: [PDFPagePlan]
    public let warnings: [PDFLayoutWarning]

    public init(documentTitle: String, settings: PDFLayoutSettings, pages: [PDFPagePlan], warnings: [PDFLayoutWarning]) {
        self.documentTitle = documentTitle
        self.settings = settings
        self.pages = pages
        self.warnings = warnings
    }

    public var contentPages: [PDFPagePlan] {
        pages.filter { !$0.isTitlePage }
    }

    public func address(pageIndex: Int, blockIndex: Int, lineIndex: Int) -> PDFContentAddress? {
        guard pages.indices.contains(pageIndex) else { return nil }
        let page = pages[pageIndex]
        guard page.blocks.indices.contains(blockIndex) else { return nil }
        let block = page.blocks[blockIndex]
        guard block.lines.indices.contains(lineIndex) else { return nil }
        let line = block.lines[lineIndex]

        return PDFContentAddress(
            documentPageNumber: page.documentPageNumber,
            screenplayPageNumber: page.screenplayPageNumber,
            blockNumber: block.blockNumber,
            paragraphNumber: block.paragraphNumber,
            lineNumber: line.lineNumber,
            sourceElementIndex: block.sourceElementIndex
        )
    }
}
