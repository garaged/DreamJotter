import Foundation

public enum IOSDeliveryPhase: String, CaseIterable, Codable, Sendable {
    case foundation
    case documentExperience
    case editor
    case organization
    case reviewAndExport
    case releaseHardening
}

public enum IOSCapability: String, CaseIterable, Codable, Sendable {
    case applicationFoundation
    case localPackageCreateOpenSave
    case autosaveAndConflictRecovery
    case semanticScreenplayEditing
    case smartEnterAndElementFormatting
    case undoRedo
    case findAndNavigation
    case characterProfiles
    case locationProfiles
    case scenePlanning
    case notesAndTodos
    case reviewFindings
    case healthReport
    case dashboard
    case fountainExport
    case textExport
    case markdownExport
    case jsonBackupRestore
    case fdxImportExport
    case productionPDFExport
    case localization
    case accessibility
    case keyboardCommands
    case privacyFilteredDiagnostics
}

public struct IOSFeatureParityItem: Equatable, Codable, Sendable {
    public let capability: IOSCapability
    public let phase: IOSDeliveryPhase
    public let requiresDeviceValidation: Bool

    public init(
        capability: IOSCapability,
        phase: IOSDeliveryPhase,
        requiresDeviceValidation: Bool = false
    ) {
        self.capability = capability
        self.phase = phase
        self.requiresDeviceValidation = requiresDeviceValidation
    }
}

public enum IOSFeatureParityCatalog {
    public static let fullDesktopParity: [IOSFeatureParityItem] = [
        .init(capability: .applicationFoundation, phase: .foundation),
        .init(capability: .localPackageCreateOpenSave, phase: .documentExperience, requiresDeviceValidation: true),
        .init(capability: .autosaveAndConflictRecovery, phase: .documentExperience, requiresDeviceValidation: true),
        .init(capability: .semanticScreenplayEditing, phase: .editor, requiresDeviceValidation: true),
        .init(capability: .smartEnterAndElementFormatting, phase: .editor, requiresDeviceValidation: true),
        .init(capability: .undoRedo, phase: .editor, requiresDeviceValidation: true),
        .init(capability: .findAndNavigation, phase: .editor),
        .init(capability: .characterProfiles, phase: .organization),
        .init(capability: .locationProfiles, phase: .organization),
        .init(capability: .scenePlanning, phase: .organization),
        .init(capability: .notesAndTodos, phase: .organization),
        .init(capability: .reviewFindings, phase: .reviewAndExport),
        .init(capability: .healthReport, phase: .reviewAndExport),
        .init(capability: .dashboard, phase: .reviewAndExport),
        .init(capability: .fountainExport, phase: .reviewAndExport),
        .init(capability: .textExport, phase: .reviewAndExport),
        .init(capability: .markdownExport, phase: .reviewAndExport),
        .init(capability: .jsonBackupRestore, phase: .reviewAndExport, requiresDeviceValidation: true),
        .init(capability: .fdxImportExport, phase: .reviewAndExport, requiresDeviceValidation: true),
        .init(capability: .productionPDFExport, phase: .reviewAndExport, requiresDeviceValidation: true),
        .init(capability: .localization, phase: .releaseHardening),
        .init(capability: .accessibility, phase: .releaseHardening, requiresDeviceValidation: true),
        .init(capability: .keyboardCommands, phase: .releaseHardening, requiresDeviceValidation: true),
        .init(capability: .privacyFilteredDiagnostics, phase: .releaseHardening)
    ]

    public static func items(in phase: IOSDeliveryPhase) -> [IOSFeatureParityItem] {
        fullDesktopParity.filter { $0.phase == phase }
    }
}
