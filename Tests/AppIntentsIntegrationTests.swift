import AppIntentsTesting
import XCTest

final class AppIntentsIntegrationTests: XCTestCase {
    @MainActor
    func testSystemResolvesQuestionsAndReturnsStreetAnswers() async throws {
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "Spyrath-Dev.TTR-Rewatched.watchkitapp")
        app.launch()
        defer { app.terminate() }

        let definitions = IntentDefinitions(bundleIdentifier: "Spyrath-Dev.TTR-Rewatched.watchkitapp")
        let questions = definitions.entities["CogStreetQuestion"]
        let cases = [
            ("Toontown Central for Cashbot", "toontownCentral-cashbot",
             "Punchline Place has the highest Cashbot percentage in Toontown Central, at 40 percent."),
            ("Toontown Central for Bossbot", "toontownCentral-bossbot",
             "Silly Street has the highest Bossbot percentage in Toontown Central, at 25 percent.")
        ]
        for (query, identifier, expected) in cases {
            let matches = try await questions.entities(matching: query)
            XCTAssertEqual(matches.count, 1, "System entity lookup failed for \(query)")
            let question = try XCTUnwrap(matches.first)
            XCTAssertEqual(question.identifier, questions.makeReference(identifier: identifier).identifier)
            let result = try await definitions.intents["BestStreetIntent"]
                .makeIntent(question: question).run()
            let answer: String = try result.value
            XCTAssertEqual(answer, expected)
        }
    }
}
