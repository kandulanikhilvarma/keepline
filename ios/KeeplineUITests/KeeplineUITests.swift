import XCTest

final class KeeplineUITests: XCTestCase {
    private func enter(_ text: String, in app: XCUIApplication) {
        let field = app.textFields["lineText"]
        if field.waitForExistence(timeout: 3) { field.tap(); field.typeText(text) }
        else { let field = app.textViews["lineText"]; field.tap(); field.typeText(text) }
    }
    private func contains(_ text: String, in app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }
    private func row(_ text: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }
    func testCreateEditAndPersistence() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test-reset"]
        app.launch()
        XCTAssertTrue(app.buttons["firstLine"].waitForExistence(timeout: 10))
        app.buttons["firstLine"].tap()
        enter("Be calm.", in: app)
        app.buttons["saveLine"].tap()
        XCTAssertTrue(contains("Be calm.", in: app).waitForExistence(timeout: 5))
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "in-sight"; shot.lifetime = .keepAlways; add(shot)
        app.terminate(); app.launchArguments = []; app.launch()
        XCTAssertTrue(contains("Be calm.", in: app).waitForExistence(timeout: 10))
        app.tabBars.buttons["Library"].tap()
        row("Be calm.", in: app).tap()
        let editor = app.textFields["lineText"].exists ? app.textFields["lineText"] : app.textViews["lineText"]
        editor.tap()
        editor.typeText(" Breathe.")
        app.buttons["saveLine"].tap()
        XCTAssertTrue(contains("Breathe.", in: app).waitForExistence(timeout: 5))
        app.terminate(); app.launch()
        XCTAssertTrue(contains("Breathe.", in: app).waitForExistence(timeout: 10))
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.buttons["Export backup"].exists)
        let settings = XCTAttachment(screenshot: app.screenshot()); settings.name = "settings"; settings.lifetime = .keepAlways; add(settings)
    }

    func testArchiveRestoreDeleteAndPin() throws {
        let app = XCUIApplication(); app.launchArguments = ["--ui-test-reset"]; app.launch()
        XCTAssertTrue(app.buttons["firstLine"].waitForExistence(timeout: 10)); app.buttons["firstLine"].tap()
        enter("Read 5 books this month.", in: app)
        app.buttons["dismissKeyboard"].tap()
        let toggle = app.switches["pinLine"]
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5))
            .withOffset(CGVector(dx: -45, dy: 0)).tap()
        XCTAssertEqual(toggle.value as? String, "1")
        let editorShot = XCTAttachment(screenshot: app.screenshot()); editorShot.name = "pinned-editor"; editorShot.lifetime = .keepAlways; add(editorShot)
        app.buttons["saveLine"].tap()
        app.tabBars.buttons["Library"].tap()
        let entry = row("Read 5 books", in: app)
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
        XCTAssertTrue(contains("Pinned", in: app).exists || entry.label.contains("Pinned"))
        entry.press(forDuration: 1.2); app.buttons["Archive"].tap()
        XCTAssertTrue(contains("No lines here", in: app).waitForExistence(timeout: 5))
        app.buttons["Archived"].tap()
        let archived = row("Read 5 books", in: app)
        XCTAssertTrue(archived.waitForExistence(timeout: 5))
        archived.press(forDuration: 1.2); app.buttons["Restore"].tap()
        app.buttons["Current"].tap()
        XCTAssertTrue(entry.waitForExistence(timeout: 5))
        entry.press(forDuration: 1.2); app.buttons["Delete"].tap()
        app.buttons["Delete line"].tap()
        XCTAssertTrue(contains("No lines here", in: app).waitForExistence(timeout: 5))
    }

    func testEmptyAndOversizedTextCannotSave() throws {
        let app = XCUIApplication(); app.launchArguments = ["--ui-test-reset"]; app.launch()
        XCTAssertTrue(app.buttons["firstLine"].waitForExistence(timeout: 10)); app.buttons["firstLine"].tap()
        XCTAssertFalse(app.buttons["saveLine"].isEnabled)
        enter(String(repeating: "a", count: 141), in: app)
        XCTAssertFalse(app.buttons["saveLine"].isEnabled)
        app.buttons["Cancel"].tap(); app.buttons["Discard changes"].tap()
        XCTAssertTrue(app.buttons["firstLine"].waitForExistence(timeout: 5))
    }
}
