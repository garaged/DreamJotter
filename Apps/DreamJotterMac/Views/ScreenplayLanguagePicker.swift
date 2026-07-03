import DreamJotterCore
import SwiftUI

struct ScreenplayLanguagePicker: View {
    @Binding var document: ProjectDocumentViewModel

    var body: some View {
        Picker("Screenplay Language", selection: Binding(
            get: { document.screenplayLanguage },
            set: { document.setScreenplayLanguage($0) }
        )) {
            Text("Automatic").tag(ScreenplayLanguageProfile.automatic)
            Text("English").tag(ScreenplayLanguageProfile.english)
            Text("Spanish (Latin America)").tag(ScreenplayLanguageProfile.spanishLatinAmerica)
        }
        .frame(width: 210)
    }
}
