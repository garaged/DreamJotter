import DreamJotterCore
import Foundation

extension MacAppViewModel {
    mutating func requestOpenPackageRespectingLanguage(at packageURL: URL) throws -> ProjectReplacementDecision {
        let decision = try requestOpenPackage(at: packageURL)
        if decision == .replaced {
            refreshCurrentDocumentLanguage(now: Date())
        }
        return decision
    }

    mutating func saveCurrentProjectRespectingLanguage(now: Date = Date()) throws -> SaveRequestResult {
        let language = currentDocument?.screenplayLanguage ?? .automatic
        return try ScreenplayParsingContext.$language.withValue(language) {
            try saveCurrentProject(now: now)
        }
    }

    mutating func saveCurrentProjectRespectingLanguage(to packageURL: URL, now: Date = Date()) throws -> SaveAsRequestResult {
        let language = currentDocument?.screenplayLanguage ?? .automatic
        return try ScreenplayParsingContext.$language.withValue(language) {
            try saveCurrentProject(to: packageURL, now: now)
        }
    }

    mutating func saveAndConfirmPendingReplacementRespectingLanguage(now: Date = Date()) throws -> SaveBeforeReplacementResult {
        let language = currentDocument?.screenplayLanguage ?? .automatic
        let result = try ScreenplayParsingContext.$language.withValue(language) {
            try saveAndConfirmPendingReplacement(now: now)
        }
        if result == .replaced {
            refreshCurrentDocumentLanguage(now: now)
        }
        return result
    }

    mutating func confirmPendingReplacementAfterExternalSaveRespectingLanguage(now: Date = Date()) throws {
        try confirmPendingReplacementAfterExternalSave(now: now)
        refreshCurrentDocumentLanguage(now: now)
    }

    mutating func saveAndConfirmPendingRestoreRespectingLanguage(now: Date = Date()) throws -> SaveBeforeRestoreResult {
        let language = currentDocument?.screenplayLanguage ?? .automatic
        let result = try ScreenplayParsingContext.$language.withValue(language) {
            try saveAndConfirmPendingRestore(now: now)
        }
        if case .restored = result {
            refreshCurrentDocumentLanguage(now: now)
        }
        return result
    }

    mutating func confirmPendingRestoreAfterExternalSaveRespectingLanguage(now: Date = Date()) throws -> RestoreResult {
        let result = try confirmPendingRestoreAfterExternalSave(now: now)
        if result.status == .restored {
            refreshCurrentDocumentLanguage(now: now)
        }
        return result
    }

    mutating func discardPendingRestoreRespectingLanguage(now: Date = Date()) -> RestoreResult {
        let result = discardPendingRestore(now: now)
        if result.status == .restored {
            refreshCurrentDocumentLanguage(now: now)
        }
        return result
    }

    mutating func restoreBackupRespectingLanguage(from data: Data, allowReplacingDirtyProject: Bool = false, now: Date = Date()) -> RestoreResult {
        let result = restoreBackup(from: data, allowReplacingDirtyProject: allowReplacingDirtyProject, now: now)
        if result.status == .restored {
            refreshCurrentDocumentLanguage(now: now)
        }
        return result
    }

    private mutating func refreshCurrentDocumentLanguage(now: Date) {
        currentDocument?.refreshParseRespectingLanguage(now: now)
    }
}
