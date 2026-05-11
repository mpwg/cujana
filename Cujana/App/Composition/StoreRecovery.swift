import SwiftUI

struct StoreRecoveryView: View {
    let context: PersistentStoreRecoveryContext
    let prepareStoreBackup: () throws -> [URL]
    let retryStartup: @MainActor () -> AppStartupState
    let startEmptyStore: @MainActor () throws -> AppStartupState
    let didUpdateStartupState: @MainActor (AppStartupState) -> Void

    @State private var backupFileURLs: [URL] = []
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var isPreparingBackup = false
    @State private var isStartingEmptyStore = false
    @State private var showsDestructiveConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(
                            "Lokale Daten wurden nicht gelöscht",
                            systemImage: "externaldrive.badge.exclamationmark"
                        )
                            .font(.headline)
                            .foregroundStyle(ColorToken.accentPrimary)

                        Text(context.reason.headline)
                            .font(.subheadline)
                            .foregroundStyle(ColorToken.textPrimary)

                        Text(context.reason.explanation)
                            .font(.subheadline)
                            .foregroundStyle(ColorToken.textSecondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Sicherung und Migration") {
                    Text("""
                    Sichere die vorhandenen Store-Dateien, bevor du Cujana mit einem leeren Store startest. Ohne \
                    Löschbestätigung bleiben die Dateien an ihrem aktuellen Ort.
                    """)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        prepareBackup()
                    } label: {
                        Label(
                            isPreparingBackup ? "Sicherung wird vorbereitet" : "Store-Dateien sichern",
                            systemImage: "externaldrive.badge.plus"
                        )
                    }
                    .disabled(isPreparingBackup || isStartingEmptyStore)

                    if !backupFileURLs.isEmpty {
                        ShareLink(items: backupFileURLs) {
                            Label("Sicherung teilen", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button {
                        didUpdateStartupState(retryStartup())
                    } label: {
                        Label("Erneut versuchen", systemImage: "arrow.clockwise")
                    }
                    .disabled(isPreparingBackup || isStartingEmptyStore)

                    Button {
                        statusMessage = """
                        Es wurde nichts geändert. Du kannst Cujana nach einem Update erneut öffnen oder die \
                        Store-Dateien vorher sichern.
                        """
                        errorMessage = nil
                    } label: {
                        Label("Später migrieren", systemImage: "clock.arrow.circlepath")
                    }
                    .disabled(isStartingEmptyStore)
                }

                Section("Leerer Neustart") {
                    Text("""
                    Diese Option entfernt die lokalen Store-Dateien erst nach deiner Bestätigung und erstellt danach \
                    einen neuen leeren Store.
                    """)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button(role: .destructive) {
                        showsDestructiveConfirmation = true
                    } label: {
                        Label(
                            isStartingEmptyStore ? "Leerer Store wird erstellt" : "Mit leerem Store starten",
                            systemImage: "trash"
                        )
                    }
                    .disabled(isPreparingBackup || isStartingEmptyStore)
                }

                RecoveryStatusSections(statusMessage: statusMessage, errorMessage: errorMessage)
            }
            .navigationTitle("Daten wiederherstellen")
            .scrollContentBackground(.hidden)
            .background(ColorToken.backgroundPrimary)
            .confirmationDialog(
                "Lokale Store-Dateien löschen?",
                isPresented: $showsDestructiveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Store-Dateien löschen und leer starten", role: .destructive) {
                    startWithEmptyStore()
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("""
                Diese Aktion löscht den lokalen SwiftData-Store auf diesem Gerät. Eine spätere Migration ist nur \
                möglich, wenn du die Store-Dateien vorher gesichert hast.
                """)
            }
        }
    }

    private func prepareBackup() {
        isPreparingBackup = true
        statusMessage = nil
        errorMessage = nil

        do {
            backupFileURLs = try prepareStoreBackup()
            statusMessage = "Die Store-Dateien wurden für die Sicherung vorbereitet."
        } catch {
            errorMessage = userFacingMessage(for: error)
        }

        isPreparingBackup = false
    }

    private func startWithEmptyStore() {
        isStartingEmptyStore = true
        statusMessage = nil
        errorMessage = nil

        do {
            didUpdateStartupState(try startEmptyStore())
        } catch {
            errorMessage = userFacingMessage(for: error)
            isStartingEmptyStore = false
        }
    }
}

struct StartupSafeModeView: View {
    let context: AppStartupFailureContext
    let prepareStoreBackup: () throws -> [URL]
    let retryStartup: @MainActor () -> AppStartupState
    let startEmptyStore: @MainActor () throws -> AppStartupState
    let didUpdateStartupState: @MainActor (AppStartupState) -> Void

    @State private var backupFileURLs: [URL] = []
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var isPreparingBackup = false
    @State private var isStartingEmptyStore = false
    @State private var showsDestructiveConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Safe-Mode aktiv", systemImage: "wrench.and.screwdriver")
                            .font(.headline)
                            .foregroundStyle(ColorToken.accentPrimary)

                        Text(context.reason.headline)
                            .font(.subheadline)
                            .foregroundStyle(ColorToken.textPrimary)

                        Text(context.reason.explanation)
                            .font(.subheadline)
                            .foregroundStyle(ColorToken.textSecondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Diagnose") {
                    LabeledContent("Fehlercode", value: context.errorSummary)

                    if let storeURL = context.storeURL ?? context.recoveryContext?.storeURL {
                        LabeledContent("Store", value: storeURL.lastPathComponent)
                    }

                    if let recoveryContext = context.recoveryContext {
                        LabeledContent("Recovery-Grund", value: recoveryContext.reason.rawValue)
                    }
                }

                Section("Wiederherstellung") {
                    Button {
                        prepareBackup()
                    } label: {
                        Label(
                            isPreparingBackup ? "Sicherung wird vorbereitet" : "Store-Dateien sichern",
                            systemImage: "externaldrive.badge.plus"
                        )
                    }
                    .disabled(isPreparingBackup || isStartingEmptyStore)

                    if !backupFileURLs.isEmpty {
                        ShareLink(items: backupFileURLs) {
                            Label("Sicherung teilen", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button {
                        didUpdateStartupState(retryStartup())
                    } label: {
                        Label("Erneut versuchen", systemImage: "arrow.clockwise")
                    }
                    .disabled(isPreparingBackup || isStartingEmptyStore)

                    Button(role: .destructive) {
                        showsDestructiveConfirmation = true
                    } label: {
                        Label(
                            isStartingEmptyStore ? "Leerer Store wird erstellt" : "Mit leerem Store starten",
                            systemImage: "trash"
                        )
                    }
                    .disabled(isPreparingBackup || isStartingEmptyStore)
                }

                RecoveryStatusSections(statusMessage: statusMessage, errorMessage: errorMessage)
            }
            .navigationTitle("Safe-Mode")
            .scrollContentBackground(.hidden)
            .background(ColorToken.backgroundPrimary)
            .confirmationDialog(
                "Lokale Store-Dateien löschen?",
                isPresented: $showsDestructiveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Store-Dateien löschen und leer starten", role: .destructive) {
                    startWithEmptyStore()
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("""
                Diese Aktion löscht den lokalen SwiftData-Store auf diesem Gerät. Sichere die Store-Dateien vorher, \
                wenn du sie später wiederherstellen möchtest.
                """)
            }
        }
    }

    private func prepareBackup() {
        isPreparingBackup = true
        statusMessage = nil
        errorMessage = nil

        do {
            backupFileURLs = try prepareStoreBackup()
            statusMessage = "Die Store-Dateien wurden für die Sicherung vorbereitet."
        } catch {
            errorMessage = userFacingMessage(for: error)
        }

        isPreparingBackup = false
    }

    private func startWithEmptyStore() {
        isStartingEmptyStore = true
        statusMessage = nil
        errorMessage = nil

        do {
            didUpdateStartupState(try startEmptyStore())
        } catch {
            errorMessage = userFacingMessage(for: error)
            isStartingEmptyStore = false
        }
    }
}

private struct RecoveryStatusSections: View {
    let statusMessage: String?
    let errorMessage: String?

    var body: some View {
        if let statusMessage {
            Section {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(ColorToken.textSecondary)
            }
        }

        if let errorMessage {
            Section {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(ColorToken.accentPrimary)
            }
        }
    }
}

private func userFacingMessage(for error: Error) -> String {
    if let localizedError = error as? LocalizedError, let description = localizedError.errorDescription {
        return description
    }

    let nsError = error as NSError
    return "Der Vorgang konnte nicht abgeschlossen werden. Fehlercode: \(nsError.domain) \(nsError.code)"
}
