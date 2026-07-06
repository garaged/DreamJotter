import UIKit

@MainActor
protocol IOSScreenplayTextViewCommandDelegate: AnyObject {
    func screenplayTextViewHasSuggestions() -> Bool
    func screenplayTextViewMoveSuggestion(_ offset: Int) -> Bool
    func screenplayTextViewAcceptSuggestion() -> Bool
    func screenplayTextViewDismissSuggestions() -> Bool
    func screenplayTextViewPerformSmartEnter()
    func screenplayTextViewPerformFormatCycle()
    func screenplayTextViewCopy() -> String?
    func screenplayTextViewCut() -> String?
    func screenplayTextViewPaste(_ text: String)
}

final class IOSScreenplayTextView: UITextView {
    weak var commandDelegate: IOSScreenplayTextViewCommandDelegate?

    override var keyCommands: [UIKeyCommand]? {
        var commands = [
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(acceptOrReturn)),
            UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(acceptOrFormat)),
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(dismissSuggestions)),
            UIKeyCommand(input: "\r", modifierFlags: [.command], action: #selector(smartEnter))
        ]
        if commandDelegate?.screenplayTextViewHasSuggestions() == true {
            commands.insert(
                UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(handleMoveUp)),
                at: 0
            )
            commands.insert(
                UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(handleMoveDown)),
                at: 1
            )
        }
        return commands
    }

    override func copy(_ sender: Any?) {
        guard let text = commandDelegate?.screenplayTextViewCopy() else {
            super.copy(sender)
            return
        }
        UIPasteboard.general.string = text
    }

    override func cut(_ sender: Any?) {
        guard let text = commandDelegate?.screenplayTextViewCut() else {
            super.cut(sender)
            return
        }
        UIPasteboard.general.string = text
    }

    override func paste(_ sender: Any?) {
        guard let text = UIPasteboard.general.string else {
            super.paste(sender)
            return
        }
        commandDelegate?.screenplayTextViewPaste(text)
    }

    @objc private func handleMoveUp() {
        _ = commandDelegate?.screenplayTextViewMoveSuggestion(-1)
    }

    @objc private func handleMoveDown() {
        _ = commandDelegate?.screenplayTextViewMoveSuggestion(1)
    }

    @objc private func acceptOrReturn() {
        guard commandDelegate?.screenplayTextViewAcceptSuggestion() == true else {
            insertText("\n")
            return
        }
    }

    @objc private func acceptOrFormat() {
        guard commandDelegate?.screenplayTextViewAcceptSuggestion() == true else {
            commandDelegate?.screenplayTextViewPerformFormatCycle()
            return
        }
    }

    @objc private func dismissSuggestions() {
        guard commandDelegate?.screenplayTextViewDismissSuggestions() == true else { return }
    }

    @objc private func smartEnter() {
        commandDelegate?.screenplayTextViewPerformSmartEnter()
    }
}
