import XCTest

@MainActor
final class CujanaScreenshotTests: XCTestCase {
    @MainActor
    private enum ScreenshotSelection {
        static let environmentKey = "CUJANA_SCREENSHOT_PAGES"

        static let storeScreens: [Screen] = [
            .init(
                route: "dashboard",
                germanSnapshotName: "01-allergien-im-blick",
                englishSnapshotName: "01-allergy-overview"
            ),
            .init(
                route: "entry",
                germanSnapshotName: "02-symptome-schnell-erfassen",
                englishSnapshotName: "02-log-symptoms-fast"
            )
        ]

        static func screens(
            from environment: [String: String] = ProcessInfo.processInfo.environment
        ) throws -> [Screen] {
            let rawSelection = configuredSelection(from: environment)
            guard let rawSelection, !rawSelection.isEmpty else {
                return storeScreens
            }

            switch rawSelection.lowercased() {
            case "store", "main", "default":
                return storeScreens
            case "all", "alle":
                return storeScreens
            default:
                return try screens(matching: rawSelection)
            }
        }

        private static func configuredSelection(from environment: [String: String]) -> String? {
            if let rawSelection = environment[environmentKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
               !rawSelection.isEmpty {
                return rawSelection
            }

            guard let cacheDirectory = try? Snapshot.getCacheDirectory() else {
                return nil
            }

            let path = cacheDirectory.appendingPathComponent("screenshot-pages.txt")
            return try? String(contentsOf: path, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        private static func screens(matching rawSelection: String) throws -> [Screen] {
            let requestedIdentifiers = rawSelection
                .split { character in
                    character == "," || character == ";" || character.isWhitespace
                }
                .map { String($0).lowercased() }
            guard !requestedIdentifiers.isEmpty else {
                return storeScreens
            }

            let screensByIdentifier = storeScreens.reduce(into: [String: Screen]()) { result, screen in
                screen.identifiers.forEach { result[$0] = screen }
            }
            let selectedScreens = requestedIdentifiers.compactMap { screensByIdentifier[$0] }
            let missingIdentifiers = requestedIdentifiers.filter { screensByIdentifier[$0] == nil }

            if !missingIdentifiers.isEmpty {
                let missingPages = missingIdentifiers.joined(separator: ", ")
                let allowedPages = storeScreens.map(\.route).joined(separator: ", ")
                throw NSError(
                    domain: "CujanaScreenshotTests",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unbekannte Screenshot-Seiten: \(missingPages). "
                            + "Erlaubt sind store, all oder: \(allowedPages)."
                    ]
                )
            }

            return selectedScreens
        }
    }

    private struct Screen {
        let route: String
        let germanSnapshotName: String
        let englishSnapshotName: String

        func snapshotName(for language: String) -> String {
            language.localizedCaseInsensitiveContains("de") ? germanSnapshotName : englishSnapshotName
        }

        var identifiers: [String] {
            [
                route,
                germanSnapshotName,
                englishSnapshotName,
                germanSnapshotName.replacingOccurrences(of: #"^\d+-"#, with: "", options: .regularExpression),
                englishSnapshotName.replacingOccurrences(of: #"^\d+-"#, with: "", options: .regularExpression)
            ].map { $0.lowercased() }
        }
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCaptureMainStoreScreens() throws {
        let screens = try ScreenshotSelection.screens()

        for screen in screens {
            let app = XCUIApplication()
            setupSnapshot(app, waitForAnimations: false)
            app.launchArguments += [
                "-cujana_screenshot_screen",
                screen.route,
                "-cujana_screenshot_seed",
                "default"
            ]
            app.launch()
            waitForStableLayout()
            snapshot(screen.snapshotName(for: Snapshot.deviceLanguage), waitForLoadingIndicator: false)
            app.terminate()
        }
    }

    func testLaunchScreenRenders() throws {
        let app = XCUIApplication()
        setupSnapshot(app, waitForAnimations: false)
        app.launchArguments += [
            "-cujana_screenshot_screen",
            "dashboard",
            "-cujana_screenshot_seed",
            "default"
        ]
        app.launch()

        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 6))
    }

    private func waitForStableLayout() {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.2))
    }
}
