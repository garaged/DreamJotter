import Foundation

public enum IOSLongScriptFixture {
    public static func screenplay(sceneCount: Int = 500) -> String {
        guard sceneCount > 0 else { return "" }
        return (1...sceneCount).map { index in
            """
            INT. ROOM \(index) - DAY

            A bounded performance fixture action paragraph for scene \(index).

            WRITER
            This dialogue line exercises character cue and dialogue layout.

            > CUT TO:
            """
        }.joined(separator: "\n\n")
    }
}
