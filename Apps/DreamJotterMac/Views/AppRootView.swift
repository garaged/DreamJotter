import AppKit
import DreamJotterCore
import SwiftUI

struct AppRootView: View {
    @State private var appModel = MacAppViewModel()
    @State private var errorMessage: String?
    @State private var replacementConfirmationMessage: String?
    @State private var restoreConfirmationMessage: String?
    @State private var isExportPickerPresented = false
    @State private var exportUIState = ExportUIState.initial()
    @State private var allowWindowClose = false
    @State private var pendingRecentRegistrationURL: URL?

    var body: some View {
        Group {
            if appModel.hasOpenProject {
                ProjectWorkspaceView(
                    document: Binding(
                        get: { appModel.currentDocument! },
                        set: { appModel.currentDocument = $0 }
                    ),
                    saveAction: saveProject,
                    saveAsAction: { _ = saveProjectAs() },
                    openAction: openProject,
                    exportAction: { openExportPicker(sourceContext: .workspace) },
                    reviewExportAction: { openExportPicker(sourceContext: .reviewMode) },
                    closeAction: closeProject
                )
            } else {
                ProjectLibraryView(
                    recentProjectURLs: appModel.recentProjectURLs,
                    createAction: createProject,
                    openAction: openProject,
                    openRecentAction: openRecentProject
                )
            }
        }
        .navigationTitle(windowTitle)
        .frame(minWidth: 1100, minHeight: 720)
        .background(WindowCloseGuardView(allowClose: $allowWindowClose, shouldClose: requestWindowClose))
        .onAppear { consumeNextNativeOpenRequest() }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterNativeOpenRequestsAvailable)) { _ in
            consumeNextNativeOpenRequest()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterNewProject)) { _ in
            createProject(String(localized: "Untitled"))
        }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterOpenProject)) { _ in openProject() }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterSaveProject)) { _ in saveProject() }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterSaveProjectAs)) { _ in _ = saveProjectAs() }
        .onReceive(NotificationCenter.default.publisher(for: .dreamJotterExportFountain)) { _ in
            openExportPicker(sourceContext: .workspace, preferredFormat: .fountain)
        }
        .sheet(isPresented: $isExportPickerPresented) {
            ExportPickerView(
                state: $exportUIState,
                presets: exportPresets,
                chooseDestinationAction: chooseExportDestination,
                exportAction: performSelectedExport,
                restoreAction: restoreBackup,
                revealAction: revealInFinder,
                cancelAction: {
                    exportUIState.applyFeedback(.canceled(sourceOperation: "export"))
                    isExportPickerPresented = false
                }
            )
        }
        .alert("DreamJotter", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("Unsaved Changes", isPresented: Binding(
            get: { replacementConfirmationMessage != nil },
            set: { if !$0 { replacementConfirmationMessage = nil } }
        )) {
            Button("Save") { saveAndConfirmPendingReplacement() }
            Button("Discard Changes", role: .destructive) { discardPendingReplacement() }
            Button("Cancel", role: .cancel) {
                appModel.cancelPendingReplacement()
                pendingRecentRegistrationURL = nil
                replacementConfirmationMessage = nil
                consumeNextNativeOpenRequest()
            }
        } message: {
            Text(replacementConfirmationMessage ?? "")
        }
        .alert("Restore Backup?", isPresented: Binding(
            get: { restoreConfirmationMessage != nil },
            set: { if !$0 { restoreConfirmationMessage = nil } }
        )) {
            Button("Save and Restore") { saveAndConfirmPendingRestore() }
            Button("Discard and Restore", role: .destructive) { discardPendingRestore() }
            Button("Cancel", role: .cancel) {
                appModel.cancelPendingRestore()
                restoreConfirmationMessage = nil
                exportUIState.applyFeedback(.canceled(sourceOperation: "restore"))
            }
        } message: {
            Text(restoreConfirmationMessage ?? "")
        }
    }

    private var windowTitle: String {
        guard let document = appModel.currentDocument else { return "DreamJotter" }
        let unsavedMarker = document.isDirty ? " *" : ""
        let location = document.packageURL == nil ? " - \(String(localized: "Unsaved"))" : ""
        return "\(document.project.metadata.title)\(unsavedMarker)\(location)"
    }

    private var exportPresets: [ExportPreset] {
        appModel.currentDocument?.project.exportPresets ?? ExportPresetCatalog.builtInPresets()
    }

    private func createProject(_ title: String) {
        pendingRecentRegistrationURL = nil
        presentReplacementDecision(appModel.requestNewProject(title: title))
    }

    private func openProject() {
        let panel = NSOpenPanel()
        panel.title = String(localized: "Open DreamJotter Package")
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        openRecentProject(url)
    }

    private func openRecentProject(_ url: URL) {
        requestOpenPackage(at: url, operation: .recentProjectOpen)
    }

    private func consumeNextNativeOpenRequest() {
        guard replacementConfirmationMessage == nil,
              let url = NativeDocumentApplicationRouter.shared.dequeuePendingPackageURL() else {
            return
        }
        requestOpenPackage(at: url, operation: .open)
    }

    private func requestOpenPackage(at url: URL, operation: AppErrorSourceOperation) {
        do {
            let decision = try appModel.requestOpenPackageRespectingLanguage(at: url)
            switch decision {
            case .replaced:
                NativeRecentDocumentRegistrar.application.note(url)
                pendingRecentRegistrationURL = nil
                consumeNextNativeOpenRequest()
            case .requiresConfirmation:
                pendingRecentRegistrationURL = url
                presentReplacementDecision(decision)
            }
        } catch {
            appModel.forgetInvalidRecentProject(url)
            pendingRecentRegistrationURL = nil
            present(error, operation: operation)
            consumeNextNativeOpenRequest()
        }
    }

    private func saveProject() {
        do {
            let result = try appModel.saveCurrentProjectRespectingLanguage()
            if result == .requiresSaveAs {
                saveProjectAs()
            } else {
                registerCurrentDocumentAsRecent()
            }
        } catch {
            present(error, operation: .save)
        }
    }

    private func closeProject() {
        pendingRecentRegistrationURL = nil
        presentReplacementDecision(appModel.requestCloseProject())
    }

    private func requestWindowClose() -> Bool {
        pendingRecentRegistrationURL = nil
        switch appModel.requestCloseWindow() {
        case .replaced:
            return true
        case .requiresConfirmation(let message):
            replacementConfirmationMessage = localized(message)
            return false
        }
    }

    private func presentReplacementDecision(_ decision: ProjectReplacementDecision) {
        if case .requiresConfirmation(let message) = decision {
            replacementConfirmationMessage = localized(message)
        }
    }

    private func saveAndConfirmPendingReplacement() {
        let shouldCloseWindow = appModel.pendingReplacement == .closeWindow
        do {
            if try appModel.saveAndConfirmPendingReplacementRespectingLanguage() == .requiresSaveAs {
                _ = saveProjectAs { finishPendingReplacementAfterSave(shouldCloseWindow: shouldCloseWindow) }
                return
            }
            replacementConfirmationMessage = nil
            registerPendingOpenedDocumentIfNeeded()
            closeWindowIfNeeded(shouldCloseWindow)
            consumeNextNativeOpenRequest()
        } catch {
            replacementConfirmationMessage = nil
            pendingRecentRegistrationURL = nil
            present(error, operation: .save)
        }
    }

    private func discardPendingReplacement() {
        do {
            let shouldCloseWindow = appModel.pendingReplacement == .closeWindow
            try appModel.discardPendingReplacement()
            replacementConfirmationMessage = nil
            registerPendingOpenedDocumentIfNeeded()
            closeWindowIfNeeded(shouldCloseWindow)
            consumeNextNativeOpenRequest()
        } catch {
            replacementConfirmationMessage = nil
            pendingRecentRegistrationURL = nil
            present(error, operation: .unknown)
        }
    }

    private func finishPendingReplacementAfterSave(shouldCloseWindow: Bool) {
        do {
            try appModel.confirmPendingReplacementAfterExternalSaveRespectingLanguage()
            replacementConfirmationMessage = nil
            registerPendingOpenedDocumentIfNeeded()
            closeWindowIfNeeded(shouldCloseWindow)
            consumeNextNativeOpenRequest()
        } catch {
            replacementConfirmationMessage = nil
            pendingRecentRegistrationURL = nil
            present(error, operation: .save)
        }
    }

    private func registerPendingOpenedDocumentIfNeeded() {
        guard let url = pendingRecentRegistrationURL,
              appModel.currentDocument?.packageURL.map(DocumentPackageIdentity.init(url:)) == DocumentPackageIdentity(url: url) else {
            pendingRecentRegistrationURL = nil
            return
        }
        NativeRecentDocumentRegistrar.application.note(url)
        pendingRecentRegistrationURL = nil
    }

    private func registerCurrentDocumentAsRecent() {
        guard let url = appModel.currentDocument?.packageURL else { return }
        NativeRecentDocumentRegistrar.application.note(url)
    }

    private func saveAndConfirmPendingRestore() {
        do {
            switch try appModel.saveAndConfirmPendingRestoreRespectingLanguage() {
            case .restored(let restoreResult):
                finishRestore(restoreResult)
            case .requiresSaveAs:
                let saveResult = saveProjectAs { finishPendingRestoreAfterSave() }
                if saveResult == .canceled {
                    appModel.cancelPendingRestore()
                    restoreConfirmationMessage = nil
                    exportUIState.applyFeedback(.canceled(sourceOperation: "restore"))
                }
            }
        } catch {
            restoreConfirmationMessage = nil
            present(error, operation: .save)
        }
    }

    private func discardPendingRestore() {
        finishRestore(appModel.discardPendingRestoreRespectingLanguage())
    }

    private func finishPendingRestoreAfterSave() {
        do {
            finishRestore(try appModel.confirmPendingRestoreAfterExternalSaveRespectingLanguage())
        } catch {
            restoreConfirmationMessage = nil
            present(error, operation: .save)
        }
    }

    private func finishRestore(_ result: RestoreResult) {
        restoreConfirmationMessage = nil
        switch result.status {
        case .restored:
            exportUIState.applyFeedback(ExportFeedback(
                kind: .success,
                userMessage: localized(result.userMessage),
                technicalDetail: result.technicalDetail,
                sourceOperation: "restore"
            ))
            isExportPickerPresented = false
        case .confirmationRequired:
            restoreConfirmationMessage = localized(result.userMessage)
            exportUIState.applyFeedback(ExportFeedback(
                kind: .warning,
                userMessage: localized(result.userMessage),
                technicalDetail: result.technicalDetail,
                sourceOperation: "restore"
            ))
        case .failed:
            exportUIState.applyFeedback(ExportFeedback(
                kind: .error,
                userMessage: localized(result.userMessage),
                technicalDetail: result.technicalDetail,
                sourceOperation: "restore"
            ))
        }
    }

    private func closeWindowIfNeeded(_ shouldCloseWindow: Bool) {
        if shouldCloseWindow {
            allowWindowClose = true
            NSApp.keyWindow?.performClose(nil)
        }
    }

    @discardableResult
    private func saveProjectAs(afterSuccessfulSave: (() -> Void)? = nil) -> SaveAsRequestResult {
        guard let document = appModel.currentDocument else { return .canceled }
        let panel = NSSavePanel()
        panel.title = String(localized: "Save DreamJotter Package")
        panel.nameFieldStringValue = "\(document.project.metadata.title).dreamjotter"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            return appModel.cancelSaveAs()
        }
        let packageURL = selectedURL.pathExtension == "dreamjotter"
            ? selectedURL
            : selectedURL.appendingPathExtension("dreamjotter")
        do {
            let result = try appModel.saveCurrentProjectRespectingLanguage(to: packageURL)
            NativeRecentDocumentRegistrar.application.note(packageURL)
            afterSuccessfulSave?()
            return result
        } catch {
            present(error, operation: .saveAs)
            return .canceled
        }
    }

    private func openExportPicker(sourceContext: ExportSourceContext, preferredFormat: ExportFormat? = nil) {
        var state = ExportUIState.initial(presets: exportPresets, sourceContext: sourceContext)
        if let preferredFormat { state.selectFormat(preferredFormat, presets: exportPresets) }
        exportUIState = state
        isExportPickerPresented = true
    }

    private func chooseExportDestination() {
        guard let document = appModel.currentDocument else { return }
        let panel = NSSavePanel()
        panel.title = exportUIState.selectedFormat == .jsonBackup
            ? String(localized: "Create DreamJotter Backup")
            : String(localized: "Export DreamJotter Project")
        panel.nameFieldStringValue = suggestedExportFilename(for: document)
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            exportUIState.setDestination(nil)
            return
        }
        let fileExtension = exportUIState.selectedFormat.fileExtension
        exportUIState.setDestination(
            selectedURL.pathExtension == fileExtension ? selectedURL : selectedURL.appendingPathExtension(fileExtension)
        )
    }

    private func performSelectedExport() {
        guard let document = appModel.currentDocument,
              let preset = exportUIState.selectedPreset(in: exportPresets) else { return }
        if exportUIState.destinationPath == nil { chooseExportDestination() }
        guard let request = exportUIState.makeRequest(projectID: document.project.metadata.id) else {
            exportUIState.applyFeedback(.canceled(sourceOperation: "export"))
            return
        }
        exportUIState.beginExport()
        let feedback = appModel.exportCurrentProject(request: request, preset: preset)
        exportUIState.applyFeedback(ExportFeedback(
            kind: feedback.kind,
            userMessage: localized(feedback.userMessage),
            technicalDetail: feedback.technicalDetail,
            outputPath: feedback.outputPath,
            canRevealInFinder: feedback.canRevealInFinder,
            sourceOperation: feedback.sourceOperation
        ))
    }

    private func restoreBackup() {
        let panel = NSOpenPanel()
        panel.title = String(localized: "Restore DreamJotter Backup")
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else {
            exportUIState.applyFeedback(.canceled(sourceOperation: "restore"))
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let result = appModel.restoreBackupRespectingLanguage(from: data)
            switch result.status {
            case .restored:
                exportUIState.applyFeedback(ExportFeedback(
                    kind: .success,
                    userMessage: localized(result.userMessage),
                    outputPath: url.path,
                    canRevealInFinder: false,
                    sourceOperation: "restore"
                ))
                isExportPickerPresented = false
            case .confirmationRequired:
                restoreConfirmationMessage = localized(result.userMessage)
                exportUIState.applyFeedback(ExportFeedback(
                    kind: .warning,
                    userMessage: localized(result.userMessage),
                    technicalDetail: result.technicalDetail,
                    sourceOperation: "restore"
                ))
            case .failed:
                exportUIState.applyFeedback(ExportFeedback(
                    kind: .error,
                    userMessage: localized(result.userMessage),
                    technicalDetail: result.technicalDetail,
                    sourceOperation: "restore"
                ))
            }
        } catch {
            let appError = AppError.wrap(error, operation: .open)
            exportUIState.applyFeedback(ExportFeedback(
                kind: .error,
                userMessage: localized(appError.userMessage),
                technicalDetail: appError.technicalDetail,
                sourceOperation: "restore"
            ))
        }
    }

    private func suggestedExportFilename(for document: ProjectDocumentViewModel) -> String {
        let preset = exportUIState.selectedPreset(in: exportPresets)
        let suggestion = preset?.filenameSuggestion ?? exportUIState.selectedFormat.displayName
        return "\(document.project.metadata.title) - \(localized(suggestion)).\(exportUIState.selectedFormat.fileExtension)"
    }

    private func revealInFinder(_ path: String) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }

    private func present(_ error: Error, operation: AppErrorSourceOperation) {
        let appError = AppError.wrap(error, operation: operation)
        let message = localized(appError.userMessage)
        if let recovery = appError.recoverySuggestion, !recovery.isEmpty {
            errorMessage = "\(message) \(localized(recovery))"
        } else {
            errorMessage = message
        }
    }

    private func localized(_ value: String) -> String {
        let errorValue = Bundle.main.localizedString(forKey: value, value: value, table: "Errors")
        if errorValue != value { return errorValue }
        return Bundle.main.localizedString(forKey: value, value: value, table: "Localizable")
    }
}

extension Notification.Name {
    static let dreamJotterNewProject = Notification.Name("DreamJotterNewProject")
    static let dreamJotterOpenProject = Notification.Name("DreamJotterOpenProject")
    static let dreamJotterSaveProject = Notification.Name("DreamJotterSaveProject")
    static let dreamJotterSaveProjectAs = Notification.Name("DreamJotterSaveProjectAs")
    static let dreamJotterExportFountain = Notification.Name("DreamJotterExportFountain")
}
