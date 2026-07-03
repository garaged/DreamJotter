import DreamJotterCore
import SwiftUI

struct ExportPickerView: View {
    @Binding var state: ExportUIState
    let presets: [ExportPreset]
    let chooseDestinationAction: () -> Void
    let exportAction: () -> Void
    let restoreAction: () -> Void
    let revealAction: (String) -> Void
    let cancelAction: () -> Void

    private var presentedPresets: [ExportPreset] {
        ExportUIState.presentedPresets(presets)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            presetPicker
            formatPicker
            destinationSection
            feedbackSection
            actionBar
        }
        .padding(20)
        .frame(minWidth: 560, idealWidth: 620)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .foregroundStyle(.secondary)
        }
    }

    private var title: String {
        switch state.sourceContext {
        case .workspace:
            String(localized: "Export Project")
        case .reviewMode:
            String(localized: "Export from Review Mode")
        case .backup:
            String(localized: "Backup and Restore")
        }
    }

    private var subtitle: String {
        switch state.sourceContext {
        case .workspace:
            String(localized: "Choose a reader-friendly format and destination.")
        case .reviewMode:
            String(localized: "The preview stays read-only while exports use the same project data.")
        case .backup:
            String(localized: "Create or restore a structured DreamJotter backup.")
        }
    }

    private var presetPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preset")
                .font(.headline)

            Picker("Preset", selection: Binding(
                get: { state.selectedPresetID },
                set: { state.selectPreset($0, presets: presentedPresets) }
            )) {
                ForEach(presentedPresets, id: \.id) { preset in
                    Text(localized(preset.title))
                        .tag(preset.id)
                }
            }
            .pickerStyle(.radioGroup)

            if let preset = state.selectedPreset(in: presentedPresets) {
                Text(localized(preset.goal))
                    .foregroundStyle(.secondary)
                if let warning = preset.privacyWarning {
                    Label(localized(warning), systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
        }
    }

    private var formatPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Format")
                .font(.headline)

            Picker("Format", selection: Binding(
                get: { state.selectedFormat },
                set: { state.selectFormat($0, presets: presentedPresets) }
            )) {
                ForEach(state.availableFormats) { format in
                    Text(localized(format.displayName))
                        .tag(format)
                        .disabled(state.disabledReason(for: format) != nil)
                }
            }
            .pickerStyle(.segmented)

            Text(localized(state.selectedFormat.writerDescription))
                .foregroundStyle(.secondary)

            if let reason = state.disabledReason(for: state.selectedFormat) {
                Label(localized(reason), systemImage: "info.circle")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
    }

    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Destination")
                .font(.headline)

            HStack {
                Text(state.destinationPath ?? String(localized: "No destination selected."))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(state.destinationPath == nil ? .secondary : .primary)

                Spacer()

                Button("Choose...") {
                    chooseDestinationAction()
                }
            }

            if state.selectedFormat == .jsonBackup {
                Text("JSON Backup creates a restore artifact. Use Restore Backup to validate and load one.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var feedbackSection: some View {
        if let feedback = state.lastFeedback {
            VStack(alignment: .leading, spacing: 8) {
                Label(localized(feedback.userMessage), systemImage: iconName(for: feedback.kind))
                    .foregroundStyle(color(for: feedback.kind))

                if let outputPath = feedback.outputPath {
                    HStack {
                        Text(outputPath)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.secondary)

                        if feedback.canRevealInFinder {
                            Button("Reveal in Finder") {
                                revealAction(outputPath)
                            }
                        }
                    }
                }
            }
            .padding(10)
            .background(color(for: feedback.kind).opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    private var actionBar: some View {
        HStack {
            Button("Restore Backup...") {
                restoreAction()
            }

            Spacer()

            Button("Cancel") {
                cancelAction()
            }

            Button(state.selectedFormat == .jsonBackup ? "Create Backup" : "Export") {
                exportAction()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(state.destinationPath == nil || state.disabledReason(for: state.selectedFormat) != nil || state.isExporting)
        }
    }

    private func localized(_ value: String) -> String {
        String(localized: String.LocalizationValue(value))
    }

    private func iconName(for kind: ExportFeedbackKind) -> String {
        switch kind {
        case .success:
            "checkmark.circle"
        case .warning:
            "exclamationmark.triangle"
        case .error:
            "xmark.octagon"
        case .canceled:
            "minus.circle"
        }
    }

    private func color(for kind: ExportFeedbackKind) -> Color {
        switch kind {
        case .success:
            .green
        case .warning:
            .orange
        case .error:
            .red
        case .canceled:
            .secondary
        }
    }
}
