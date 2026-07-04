import SwiftUI

struct AboutDreamJotterView: View {
    private let release = ReleaseIdentity.current()

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.book.closed.fill")
                .font(.system(size: 64))
                .accessibilityHidden(true)
            Text("DreamJotter")
                .font(.largeTitle.bold())
            Text("A local-first screenplay writing application for macOS.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Text("Version \(release.version) (\(release.build))")
                .font(.callout.monospacedDigit())
            Text("Copyright © 2026 DreamJotter contributors")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(width: 440)
        .accessibilityElement(children: .contain)
    }
}

struct DreamJotterHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("DreamJotter Help")
                    .font(.largeTitle.bold())

                helpSection(
                    "Start writing",
                    "Create a project, enter screenplay text in the editor, and use Smart Enter to move between semantic screenplay elements. Save creates a .dreamjotter package that remains under your control."
                )
                helpSection(
                    "Open and recover projects",
                    "Open .dreamjotter packages from DreamJotter, Finder, Open With, or Recent Documents. If a package cannot be opened, DreamJotter does not rewrite it automatically; export diagnostics and choose a backup instead."
                )
                helpSection(
                    "Keyboard essentials",
                    "Command-N creates a project, Command-O opens one, Command-S saves, Shift-Command-S saves a copy, Command-Z undoes, and Shift-Command-Z redoes."
                )
                helpSection(
                    "Export and backup",
                    "Use Export for PDF, Fountain, FDX, text, Markdown, and JSON backup workflows. Keep independent backups before major revisions or migration."
                )
                helpSection(
                    "Accessibility",
                    "DreamJotter exposes screenplay element semantics to VoiceOver and supports keyboard navigation through the primary writing workflow."
                )
            }
            .padding(28)
            .frame(maxWidth: 720, alignment: .leading)
        }
    }

    private func helpSection(_ title: LocalizedStringKey, _ text: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title3.bold())
            Text(text).textSelection(.enabled)
        }
    }
}

struct PrivacyStatementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Statement")
                    .font(.largeTitle.bold())
                Text("DreamJotter is local-first. Projects are stored in files you choose, and the application does not require an account or cloud service for normal writing workflows.")
                Text("DreamJotter does not upload screenplay content, diagnostics, or usage telemetry. Support diagnostics are exported only when you explicitly choose a destination. The default diagnostics report contains application version, operating system, architecture, locale, package status, and a bounded recent error summary. It does not contain screenplay text.")
                Text("Exports and backups are written only to destinations you select. macOS and third-party storage providers may apply their own privacy practices to those destinations.")
                Text("Review a diagnostics file before sharing it. You remain in control of every exported file.")
                    .fontWeight(.semibold)
            }
            .padding(28)
            .frame(maxWidth: 720, alignment: .leading)
            .textSelection(.enabled)
        }
    }
}

struct OnboardingView: View {
    @AppStorage("dreamjotter.onboardingCompleted") private var onboardingCompleted = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Welcome to DreamJotter")
                .font(.largeTitle.bold())
            Label("Write with semantic screenplay elements", systemImage: "text.alignleft")
            Label("Keep projects locally in .dreamjotter packages", systemImage: "folder.badge.gearshape")
            Label("Export PDF, Fountain, FDX, text, and backups", systemImage: "square.and.arrow.up")
            Label("Use Help for shortcuts, recovery, and privacy details", systemImage: "questionmark.circle")
            Spacer()
            HStack {
                Spacer()
                Button("Start Writing") {
                    onboardingCompleted = true
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(28)
        .frame(width: 560, height: 360)
    }
}
