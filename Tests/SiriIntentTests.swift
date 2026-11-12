import XCTest
import AppIntents

final class SiriIntentTests: XCTestCase {
    func testActualAppDataRanksCashbotAndLawbotStreets() {
        let central = Neighborhood.all.first { $0.name == "Toontown Central" }!
        let cashbot = StreetRanking.bestStreet(in: central, for: .cashbot)
        XCTAssertEqual(cashbot?.streets.map(\.name), ["Punchline Place"])
        XCTAssertEqual(cashbot?.percentage, 40)

        let lawbot = StreetRanking.bestStreet(in: central, for: .lawbot)
        XCTAssertEqual(lawbot?.streets.map(\.name), ["Loopy Lane"])
        XCTAssertEqual(lawbot?.percentage, 70)
    }

    func testRepresentativePlaygroundAndCogCombinationsUseActualCatalog() {
        let dock = Neighborhood.all.first { $0.name == "Donald's Dock" }!
        XCTAssertEqual(StreetRanking.bestStreet(in: dock, for: .cashbot)?.streets.map(\.name), ["Seaweed Street"])
        XCTAssertEqual(StreetRanking.bestStreet(in: dock, for: .cashbot)?.percentage, 90)

        let gardens = Neighborhood.all.first { $0.name == "Daisy Gardens" }!
        XCTAssertEqual(StreetRanking.bestStreet(in: gardens, for: .lawbot)?.streets.map(\.name), ["Maple Street"])
        XCTAssertEqual(StreetRanking.bestStreet(in: gardens, for: .lawbot)?.percentage, 70)
    }

    func testTiedStreetsAreAllReturnedAndCanBeSpoken() {
        let tied = Neighborhood(name: "Test Playground", streets: [
            Street(name: "First Street", cogPercentages: CogPercentage(bossbot: nil, lawbot: nil, cashbot: 80, sellbot: nil)),
            Street(name: "Second Street", cogPercentages: CogPercentage(bossbot: nil, lawbot: nil, cashbot: 80, sellbot: nil)),
            Street(name: "Unknown Street", cogPercentages: CogPercentage(bossbot: nil, lawbot: nil, cashbot: nil, sellbot: nil))
        ])
        let result = StreetRanking.bestStreet(in: tied, for: .cashbot)
        XCTAssertEqual(result?.streets.map(\.name), ["First Street", "Second Street"])
        XCTAssertEqual(result?.percentage, 80)

        let intent = BestStreetIntent()
        intent.question = CogStreetQuestion(id: "toontownCentral-cashbot", playground: .toontownCentral, cog: .cashbot)
        XCTAssertEqual(
            intent.spokenResponse(neighborhoods: [Neighborhood(name: "Toontown Central", streets: tied.streets)]),
            "First Street, Second Street share the highest Cashbot percentage in Toontown Central, at 80 percent."
        )
    }

    func testMissingPercentagesAreSkippedAndAllMissingReturnsNoResult() {
        let neighborhood = Neighborhood(name: "Partial", streets: [
            Street(name: "Missing", cogPercentages: CogPercentage(bossbot: nil, lawbot: nil, cashbot: nil, sellbot: nil)),
            Street(name: "Known zero", cogPercentages: CogPercentage(bossbot: nil, lawbot: nil, cashbot: 0, sellbot: nil))
        ])
        XCTAssertEqual(StreetRanking.bestStreet(in: neighborhood, for: .cashbot)?.streets.map(\.name), ["Known zero"])
        XCTAssertEqual(StreetRanking.bestStreet(in: neighborhood, for: .cashbot)?.percentage, 0)
        XCTAssertNil(StreetRanking.bestStreet(in: neighborhood, for: .lawbot))
        XCTAssertNil(StreetRanking.bestStreet(in: Neighborhood(name: "Empty", streets: []), for: .cashbot))
    }

    func testEntityQuerySupportsCurrentPlaygroundsCogsAndAliases() async throws {
        let query = CogStreetQuestionQuery()
        let suggestions = try await query.suggestedEntities()
        XCTAssertEqual(suggestions.count, Playground.allCases.count * CogType.allCases.count)

        let cash = try await query.entities(matching: "best street in toon town central for cash balls")
        XCTAssertEqual(cash.map(\.id), ["toontownCentral-cashbot"])
        let law = try await query.entities(matching: "highest Lawbot percentage in Daisy Gardens")
        XCTAssertEqual(law.map(\.id), ["daisyGardens-lawbot"])

        let ambiguousCog = try await query.entities(matching: "which street has the highest passport percentage in toon town central")
        XCTAssertTrue(ambiguousCog.isEmpty)

        let splitCashbot = try await query.entities(matching: "which street has the highest cash-back percentage in town central")
        XCTAssertEqual(splitCashbot.map(\.id), ["toontownCentral-cashbot"])

        let fullMishearing = try await query.entities(matching: "i found this on the web for which street has the highest pass-port percentage in town town central with ttr re-watched")
        XCTAssertTrue(fullMishearing.isEmpty)

        let bossbot = try await query.entities(matching: "best street in toontown central for bossbot")
        XCTAssertEqual(bossbot.map(\.id), ["toontownCentral-bossbot"])

        if #available(watchOS 10.0, *) {
            let synonyms = CogStreetQuestion.all.first { $0.id == "toontownCentral-cashbot" }!
                .displayRepresentation.synonyms.map { String(localized: $0) }
            XCTAssertTrue(synonyms.contains("Town Central for Cash board"))
        }

        let unsupportedPhrase = try await query.entities(matching: "best coke street")
        XCTAssertTrue(unsupportedPhrase.isEmpty)
        let unsupportedIdentifier = try await query.entities(for: ["unsupported-playground-cog"])
        XCTAssertTrue(unsupportedIdentifier.isEmpty)
    }

    func testIntentSpokenResponseUsesActualDataAndNamesPercentage() {
        let intent = BestStreetIntent()
        intent.question = CogStreetQuestion(id: "toontownCentral-cashbot", playground: .toontownCentral, cog: .cashbot)
        XCTAssertEqual(intent.spokenResponse(), "Punchline Place has the highest Cashbot percentage in Toontown Central, at 40 percent.")
    }

    func testBossbotResponseForToontownCentral() {
        let intent = BestStreetIntent()
        intent.question = CogStreetQuestion(id: "toontownCentral-bossbot", playground: .toontownCentral, cog: .bossbot)
        XCTAssertEqual(intent.spokenResponse(), "Silly Street has the highest Bossbot percentage in Toontown Central, at 25 percent.")
    }

    func testIntentPerformExecutesProductionResponsePath() async throws {
        let intent = BestStreetIntent()
        intent.question = CogStreetQuestion(id: "daisyGardens-lawbot", playground: .daisyGardens, cog: .lawbot)
        _ = try await intent.perform()
        XCTAssertEqual(intent.spokenResponse(), "Maple Street has the highest Lawbot percentage in Daisy Gardens, at 70 percent.")
    }

    func testIntentGracefullyReportsMissingStreetData() {
        let intent = BestStreetIntent()
        intent.question = CogStreetQuestion(id: "theBrrgh-sellbot", playground: .theBrrgh, cog: .sellbot)
        XCTAssertEqual(intent.spokenResponse(neighborhoods: []), "I couldn't find a Sellbot percentage for The Brrgh.")
    }
}
