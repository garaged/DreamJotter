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
            return "Export Project"
        case .reviewMode:
            return "Export from Review Mode"
        case .backup:
            return "Backup and Restore"
        }
    }

    private var subtitle: String {
        switch state.sourceContext {
        case .workspace:
            return "Choose a reader-friendly format and destination."
        case .reviewMode:
            return "The preview stays read-only while exports use the same project data."
        case .backup:
            return "Create or restore a structured DreamJotter backup."
        }
    }

    private var presetPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preset")
                .font(.headline)

            Picker("Preset", selection: Binding(
                get: { state.selectedPresetID },
                set: { state.selectPreset($0, presets: presets) }
            )) {
                ForEach(presets, id: \.id) { preset in
                    Text(preset.title)
                        .tag(preset.id)
                }
            }
            .pickerStyle(.radioGroup)

            if let preset = state.selectedPreset(in: presets) {
                Text(preset.goal)
                    .foregroundStyle(.secondary)
                if let warning = preset.privacyWarning {
                    Label(warning, systemImage: "exclamationmark.triangle")
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
                set: { state.selectFormat($0, presets: presets) }
            )) {
                ForEach(state.availableFormats) { format in
                    Text(format.displayName)
                        .tag(format)
                        .disabled(state.disabledReason(for: format) != nil)
                }
            }
            .pickerStyle(.segmented)

            Text(state.selectedFormat.writerDescription)
                .foregroundStyle(.secondary)

            if let reason = state.disabledReason(for: state.selectedFormat) {
                Label(reason, systemImage: "info.circle")
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
                Text(state.destinationPath ?? "No destination selected.")
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
                Label(feedback.userMessage, systemImage: iconName(for: feedback.kind))
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

    private func iconName(for kind: ExportFeedbackKind) -> String {
        switch kind {
        case .success:
            return "checkmark.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.octagon"
        case .canceled:
            return "minus.circle"
        }
    }

    private func color(for kind: ExportFeedbackKind) -> Color {
        switch kind {
        case .success:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .canceled:
            return .secondary
        }
    }
}
