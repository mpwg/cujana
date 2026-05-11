import XCTest

@MainActor
final class CujanaUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDashboardSymptomEntryAppearsInJournal() throws {
        let app = XCUIApplication()
        launchDashboardDemo(app)

        XCTAssertTrue(app.staticTexts["Wie fühlst du dich heute?"].waitForExistence(timeout: 6))

        app.buttons["Symptome erfassen"].tap()
        XCTAssertTrue(app.staticTexts["Symptome"].waitForExistence(timeout: 3))

        app.buttons["Laufende Nase"].tap()
        app.buttons["Mittel"].tap()

        let saveButton = app.buttons["Eintrag speichern"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(app.buttons["Symptome erfassen"].waitForExistence(timeout: 4))

        app.tabBars.buttons["Einträge"].tap()
        XCTAssertTrue(app.navigationBars["Einträge"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.descendants(matching: .any)["journal-entry-runnyNose"].waitForExistence(timeout: 4))
    }

    func testMainScreensPassAccessibilityAudit() throws {
        let app = XCUIApplication()
        launchDashboardDemo(app)

        XCTAssertTrue(app.buttons["Symptome erfassen"].waitForExistence(timeout: 6))
        try performAccessibilityAudit(app)

        app.buttons["Symptome erfassen"].tap()
        XCTAssertTrue(app.staticTexts["Symptome"].waitForExistence(timeout: 3))
        try performAccessibilityAudit(app)
    }

    private func performAccessibilityAudit(_ app: XCUIApplication) throws {
        try app.performAccessibilityAudit { issue in
            if self.isBehindPersistentBottomBar(issue: issue, app: app) {
                print(
                    "Ignored offscreen accessibility audit issue behind bottom bar: "
                        + "\(issue.compactDescription) "
                        + "\(issue.detailedDescription)"
                        + " Element: \(String(describing: issue.element))"
                )
                return true
            }

            print(
                "Accessibility audit issue: "
                    + "\(issue.compactDescription) "
                    + "\(issue.detailedDescription)"
                    + " Element: \(String(describing: issue.element))"
            )
            return false
        }
    }

    private func isBehindPersistentBottomBar(
        issue: XCUIAccessibilityAuditIssue,
        app: XCUIApplication
    ) -> Bool {
        let saveButton = app.buttons["Eintrag speichern"]
        guard saveButton.exists, let element = issue.element else {
            return false
        }

        return element.frame.minY >= saveButton.frame.minY
    }

    private func launchDashboardDemo(_ app: XCUIApplication) {
        app.launchArguments += [
            "-ui_testing",
            "-cujana_screenshot_screen",
            "dashboard",
            "-cujana_screenshot_seed",
            "default"
        ]
        app.launch()
    }
}
