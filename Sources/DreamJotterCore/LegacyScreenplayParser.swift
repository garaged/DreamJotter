import Foundation

enum LegacyScreenplayParser {
    static func parse(_ source: String) -> ScreenplayDocument {
        let lines = source
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        var index = 0
        var elements: [ScriptElement] = []
        var scenes: [Scene] = []
        var characters: [String] = []
        var diagnostics: [ScreenplayDiagnostic] = []
        var currentCharacter: String?

        let titleLines = consumeTitlePage(from: lines, index: &index)
        if !titleLines.isEmpty {
            elements.append(ScriptElement(
                kind: .titlePage,
                text: titleLines.joined(separator: "\n"),
                paragraphType: .titlePage
            ))
        }

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                currentCharacter = nil
                index += 1
                continue
            }

            if let noteText = noteReferenceText(from: line) {
                elements.append(ScriptElement(kind: .noteReference, text: noteText, paragraphType: .note))
                currentCharacter = nil
                index += 1
                continue
            }

            if line == "===" {
                elements.append(ScriptElement(kind: .pageBreak, text: line, paragraphType: .pageBreak))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix("%%") {
                elements.append(ScriptElement(
                    kind: .section,
                    text: forcedText(from: line, markerCount: 2),
                    paragraphType: .montage
                ))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix("!!") {
                elements.append(ScriptElement(
                    kind: .shot,
                    text: forcedText(from: line, markerCount: 2),
                    paragraphType: .shot
                ))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix("+") {
                elements.append(ScriptElement(
                    kind: .action,
                    text: forcedText(from: line, markerCount: 1),
                    paragraphType: .characterIntroduction
                ))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix(":") {
                elements.append(ScriptElement(
                    kind: .dialogue,
                    text: forcedText(from: line, markerCount: 1),
                    characterName: currentCharacter,
                    paragraphType: .dialogue
                ))
                index += 1
                continue
            }

            if line.hasPrefix("#") {
                elements.append(ScriptElement(
                    kind: .section,
                    text: forcedText(from: line, markerCount: line.prefix(while: { $0 == "#" }).count),
                    paragraphType: .section
                ))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix("="), line != "===" {
                elements.append(ScriptElement(
                    kind: .synopsis,
                    text: forcedText(from: line, markerCount: 1),
                    paragraphType: .synopsis
                ))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix("!") {
                elements.append(ScriptElement(
                    kind: .action,
                    text: forcedText(from: line, markerCount: 1),
                    paragraphType: .action
                ))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix("@") {
                let characterName = forcedText(from: line, markerCount: 1)
                elements.append(ScriptElement(
                    kind: .characterCue,
                    text: characterName,
                    paragraphType: .characterCue
                ))
                appendUnique(characterName, to: &characters)
                currentCharacter = characterName
                index += 1
                continue
            }

            if line.hasPrefix(">") {
                elements.append(ScriptElement(
                    kind: .transition,
                    text: forcedText(from: line, markerCount: 1),
                    paragraphType: .transition
                ))
                currentCharacter = nil
                index += 1
                continue
            }

            if line.hasPrefix("."), isSceneHeading(String(line.dropFirst()).trimmingCharacters(in: .whitespaces)) {
                let heading = String(line.dropFirst()).trimmingCharacters(in: .whitespaces)
                elements.append(ScriptElement(kind: .sceneHeading, text: heading, paragraphType: .sceneHeading))
                scenes.append(scene(from: heading))
                currentCharacter = nil
                index += 1
                continue
            }

            if isSceneHeading(line) {
                elements.append(ScriptElement(kind: .sceneHeading, text: line, paragraphType: .sceneHeading))
                scenes.append(scene(from: line))
                currentCharacter = nil
                index += 1
                continue
            }

            if isInvalidSceneHeading(line) {
                elements.append(ScriptElement(kind: .unknown, text: line, paragraphType: .unknown))
                diagnostics.append(.legacyInvalidSceneHeading(text: line))
                currentCharacter = nil
                index += 1
                continue
            }

            if isTransition(line) {
                elements.append(ScriptElement(kind: .transition, text: line, paragraphType: .transition))
                currentCharacter = nil
                index += 1
                continue
            }

            if isShot(line) {
                elements.append(ScriptElement(kind: .shot, text: line, paragraphType: .shot))
                currentCharacter = nil
                index += 1
                continue
            }

            if isCharacterCue(line, in: lines, at: index) {
                elements.append(ScriptElement(kind: .characterCue, text: line, paragraphType: .characterCue))
                appendUnique(line, to: &characters)
                currentCharacter = line
                index += 1
                continue
            }

            if line.hasPrefix("(") {
                if line.hasSuffix(")") {
                    elements.append(ScriptElement(
                        kind: .parenthetical,
                        text: line,
                        characterName: currentCharacter,
                        paragraphType: .parenthetical
                    ))
                    index += 1
                } else {
                    let malformed = consumeParagraph(from: lines, index: &index)
                    elements.append(ScriptElement(
                        kind: .unknown,
                        text: malformed,
                        characterName: currentCharacter,
                        paragraphType: .unknown
                    ))
                    diagnostics.append(.legacyMalformedParenthetical(text: line))
                }
                continue
            }

            if let currentCharacter {
                elements.append(ScriptElement(
                    kind: .dialogue,
                    text: line,
                    characterName: currentCharacter,
                    paragraphType: .dialogue
                ))
                index += 1
                continue
            }

            let paragraph = consumeParagraph(from: lines, index: &index)
            if let firstLine = paragraph.components(separatedBy: "\n").first,
               isUppercaseLike(firstLine),
               paragraph.contains("\n") {
                diagnostics.append(.legacyAmbiguousUppercaseLine(text: firstLine))
            }
            elements.append(ScriptElement(kind: .action, text: paragraph, paragraphType: .action))
            currentCharacter = nil
        }

        return ScreenplayDocument(elements: elements, scenes: scenes, characters: characters, diagnostics: diagnostics)
    }

    private static func consumeTitlePage(from lines: [String], index: inout Int) -> [String] {
        var titleLines: [String] = []
        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                if !titleLines.isEmpty {
                    index += 1
                    break
                }
                index += 1
                continue
            }
            guard line.range(of: #"^[A-Za-z][A-Za-z ]*:"#, options: .regularExpression) != nil else { break }
            titleLines.append(line)
            index += 1
        }
        return titleLines
    }

    private static func consumeParagraph(from lines: [String], index: inout Int) -> String {
        var paragraph: [String] = []
        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            if line.isEmpty { break }
            paragraph.append(line)
            index += 1
        }
        return paragraph.joined(separator: "\n")
    }

    private static func isSceneHeading(_ line: String) -> Bool {
        line.range(of: #"^(INT\.|EXT\.|INT\./EXT\.|EXT\./INT\.)\s+.+"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private static func isInvalidSceneHeading(_ line: String) -> Bool {
        line.range(of: #"^(INT|EXT|INT/EXT|EXT/INT)\s+.+"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private static func scene(from heading: String) -> Scene {
        let body = heading.replacingOccurrences(
            of: #"^(INT\.|EXT\.|INT\./EXT\.|EXT\./INT\.)\s+"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        let parts = body.components(separatedBy: " - ")
        return Scene(
            heading: heading,
            location: parts.first?.trimmingCharacters(in: .whitespaces) ?? body,
            timeOfDay: parts.count > 1 ? parts.last?.trimmingCharacters(in: .whitespaces) : nil
        )
    }

    private static func isTransition(_ line: String) -> Bool {
        let uppercaseLine = line.uppercased()
        return uppercaseLine.hasSuffix(" TO:")
            || uppercaseLine == "CUT TO:"
            || uppercaseLine == "CORTE A:"
            || uppercaseLine == "FADE OUT."
    }

    private static func isShot(_ line: String) -> Bool {
        let uppercaseLine = line.uppercased()
        return uppercaseLine.hasSuffix(":")
            && ["CLOSE ON:", "ANGLE ON:", "WIDE SHOT:", "INSERT:"].contains(uppercaseLine)
    }

    private static func isCharacterCue(_ line: String, in lines: [String], at index: Int) -> Bool {
        guard isUppercaseLike(line), !isTransition(line), !isInvalidSceneHeading(line) else { return false }
        guard line.split(whereSeparator: \.isWhitespace).count <= 3 else { return false }
        guard let next = nextLine(after: index, in: lines), !next.crossedBlankBoundary else { return false }
        let nextLine = next.text
        if nextLine.hasPrefix("(") || nextLine.hasPrefix(":") { return true }
        return !isUppercaseLike(nextLine)
            && !isSceneHeading(nextLine)
            && !isTransition(nextLine)
            && !isInvalidSceneHeading(nextLine)
            && !hasExplicitStructuralMarker(nextLine)
    }

    private static func nextLine(after index: Int, in lines: [String]) -> (text: String, crossedBlankBoundary: Bool)? {
        var nextIndex = index + 1
        var crossedBlankBoundary = false
        while nextIndex < lines.count {
            let line = lines[nextIndex].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                crossedBlankBoundary = true
                nextIndex += 1
                continue
            }
            return (line, crossedBlankBoundary)
        }
        return nil
    }

    private static func hasExplicitStructuralMarker(_ line: String) -> Bool {
        ["!", "@", ">", ".", "#", "=", "+", "%%", "!!", "[[", "==="].contains {
            line.hasPrefix($0)
        }
    }

    private static func isUppercaseLike(_ line: String) -> Bool {
        let letters = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        guard !letters.isEmpty else { return false }
        return line == line.uppercased()
    }

    private static func noteReferenceText(from line: String) -> String? {
        guard line.hasPrefix("[["), line.hasSuffix("]]" ) else { return nil }
        return String(line.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
    }

    private static func forcedText(from line: String, markerCount: Int) -> String {
        String(line.dropFirst(markerCount)).trimmingCharacters(in: .whitespaces)
    }

    private static func appendUnique(_ value: String, to values: inout [String]) {
        if !values.contains(value) { values.append(value) }
    }
}

private extension ScreenplayDiagnostic {
    static func legacyAmbiguousUppercaseLine(text: String) -> ScreenplayDiagnostic {
        ScreenplayDiagnostic(code: "ambiguousUppercaseLine", message: "Uppercase text was preserved without creating a character cue because dialogue context was not clear.", text: text)
    }

    static func legacyInvalidSceneHeading(text: String) -> ScreenplayDiagnostic {
        ScreenplayDiagnostic(code: "invalidSceneHeading", message: "Scene-like text is missing a supported scene heading prefix pattern.", text: text)
    }

    static func legacyMalformedParenthetical(text: String) -> ScreenplayDiagnostic {
        ScreenplayDiagnostic(code: "malformedParenthetical", message: "Parenthetical-like text is missing a closing parenthesis and must be preserved.", text: text)
    }
}
