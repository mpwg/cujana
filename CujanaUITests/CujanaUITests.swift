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
        XCTAssertTrue(app.staticTexts["Welche Symptome hast du?"].waitForExistence(timeout: 3))

        app.buttons["Laufende Nase"].tap()
        app.buttons["Mittel"].tap()

        let saveButton = app.buttons["Eintrag speichern"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(app.buttons["Symptome erfassen"].waitForExistence(timeout: 4))

        app.tabBars.buttons["Einträge"].tap()
        XCTAssertTrue(app.navigationBars["Einträge"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["journal-entry-runnyNose"].waitForExistence(timeout: 4))
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
