import XCTest

final class KeeplineUITests: XCTestCase {
    func testCreateEditAndPersistence() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test-reset"]
        app.launch()
        XCTAssertTrue(app.buttons["firstLine"].waitForExistence(timeout: 10))
        app.buttons["firstLine"].tap()
        let field = app.textFields["lineText"]
        let multiline = app.textViews["lineText"]
        if field.waitForExistence(timeout: 3) { field.tap(); field.typeText("Be calm.") }
        else { multiline.tap(); multiline.typeText("Be calm.") }
        app.buttons["saveLine"].tap()
        XCTAssertTrue(app.staticTexts["Be calm."].waitForExistence(timeout: 5))
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = "in-sight"; shot.lifetime = .keepAlways; add(shot)
        app.terminate(); app.launchArguments = []; app.launch()
        XCTAssertTrue(app.staticTexts["Be calm."].waitForExistence(timeout: 10))
        app.tabBars.buttons["Library"].tap()
        app.buttons.containing(.staticText, identifier: "Be calm.").firstMatch.tap()
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["Be calm."].waitForExistence(timeout: 3))
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.buttons["Export backup"].exists)
        let settings = XCTAttachment(screenshot: app.screenshot()); settings.name = "settings"; settings.lifetime = .keepAlways; add(settings)
    }
}
