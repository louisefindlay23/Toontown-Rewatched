import AppIntents

// The watch UI and Siri share this catalog as their only source of street data.
struct Neighborhood: Identifiable {
    let id = UUID()
    let name: String
    let streets: [Street]

    static let all: [Neighborhood] = [
        Neighborhood(name: "Toontown Central", streets: [
            Street(name: "Punchline Place", cogPercentages: CogPercentage(bossbot: 10, lawbot: 10, cashbot: 40, sellbot: 40)),
            Street(name: "Silly Street", cogPercentages: CogPercentage(bossbot: 25, lawbot: 25, cashbot: 25, sellbot: 25)),
            Street(name: "Loopy Lane", cogPercentages: CogPercentage(bossbot: 10, lawbot: 70, cashbot: 10, sellbot: 10))
        ]),
        Neighborhood(name: "Donald's Dock", streets: [
            Street(name: "Barnacle Boulevard", cogPercentages: CogPercentage(bossbot: 90, lawbot: 10, cashbot: 0, sellbot: 0)),
            Street(name: "Seaweed Street", cogPercentages: CogPercentage(bossbot: 0, lawbot: 0, cashbot: 90, sellbot: 10)),
            Street(name: "Lighthouse Lane", cogPercentages: CogPercentage(bossbot: 40, lawbot: 40, cashbot: 10, sellbot: 10))
        ]),
        Neighborhood(name: "Daisy Gardens", streets: [
            Street(name: "Elm Street", cogPercentages: CogPercentage(bossbot: 0, lawbot: 20, cashbot: 10, sellbot: 70)),
            Street(name: "Maple Street", cogPercentages: CogPercentage(bossbot: 10, lawbot: 70, cashbot: 0, sellbot: 20)),
            Street(name: "Oak Street", cogPercentages: CogPercentage(bossbot: 5, lawbot: 5, cashbot: 5, sellbot: 85))
        ]),
        Neighborhood(name: "Minnie's Melodyland", streets: [
            Street(name: "Alto Avenue", cogPercentages: CogPercentage(bossbot: 0, lawbot: 0, cashbot: 50, sellbot: 50)),
            Street(name: "Baritone Boulevard", cogPercentages: CogPercentage(bossbot: 0, lawbot: 0, cashbot: 90, sellbot: 10)),
            Street(name: "Tenor Terrace", cogPercentages: CogPercentage(bossbot: 50, lawbot: 50, cashbot: 0, sellbot: 0))
        ]),
        Neighborhood(name: "The Brrgh", streets: [
            Street(name: "Walrus Way", cogPercentages: CogPercentage(bossbot: 90, lawbot: 10, cashbot: 0, sellbot: 0)),
            Street(name: "Sleet Street", cogPercentages: CogPercentage(bossbot: 10, lawbot: 20, cashbot: 30, sellbot: 40)),
            Street(name: "Polar Place", cogPercentages: CogPercentage(bossbot: 5, lawbot: 85, cashbot: 5, sellbot: 5))
        ]),
        Neighborhood(name: "Donald's Dreamland", streets: [
            Street(name: "Lullaby Lane", cogPercentages: CogPercentage(bossbot: 25, lawbot: 25, cashbot: 25, sellbot: 25)),
            Street(name: "Pajama Place", cogPercentages: CogPercentage(bossbot: 5, lawbot: 5, cashbot: 85, sellbot: 5))
        ])
    ]
}

struct Street: Identifiable {
    let id = UUID()
    let name: String
    let cogPercentages: CogPercentage
}

struct CogPercentage {
    let bossbot: Int?
    let lawbot: Int?
    let cashbot: Int?
    let sellbot: Int?
}

enum CogType: String, AppEnum {
    case bossbot, lawbot, cashbot, sellbot
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Cog type")
    static var caseDisplayRepresentations: [CogType: DisplayRepresentation] = [
        .bossbot: "Bossbot", .lawbot: "Lawbot", .cashbot: "Cashbot", .sellbot: "Sellbot"
    ]

    var spokenName: String { rawValue.capitalized }
    var spokenAliases: [String] {
        switch self {
        case .bossbot: ["Bossbot", "Bossbots", "Boss bot", "Boss bots"]
        case .lawbot: ["Lawbot", "Lawbots", "Law bot", "Law bots"]
        case .cashbot: ["Cashbot", "Cashbots", "Cash bot", "Cash bots", "Cash board", "Cash ball", "Cash balls", "Cash box", "Cash boxes"]
        case .sellbot: ["Sellbot", "Sellbots", "Sell bot", "Sell bots"]
        }
    }

    func percentage(in street: Street) -> Int? {
        switch self {
        case .bossbot: street.cogPercentages.bossbot
        case .lawbot: street.cogPercentages.lawbot
        case .cashbot: street.cogPercentages.cashbot
        case .sellbot: street.cogPercentages.sellbot
        }
    }
}

enum Playground: String, AppEnum {
    case toontownCentral, donaldsDock, daisyGardens, minniesMelodyland, theBrrgh, donaldsDreamland
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "playground")
    static var caseDisplayRepresentations: [Playground: DisplayRepresentation] = [
        .toontownCentral: "Toontown Central", .donaldsDock: "Donald's Dock", .daisyGardens: "Daisy Gardens",
        .minniesMelodyland: "Minnie's Melodyland", .theBrrgh: "The Brrgh", .donaldsDreamland: "Donald's Dreamland"
    ]

    var neighborhoodName: String {
        switch self {
        case .toontownCentral: "Toontown Central"
        case .donaldsDock: "Donald's Dock"
        case .daisyGardens: "Daisy Gardens"
        case .minniesMelodyland: "Minnie's Melodyland"
        case .theBrrgh: "The Brrgh"
        case .donaldsDreamland: "Donald's Dreamland"
        }
    }
    var spokenAliases: [String] {
        switch self {
        case .toontownCentral: ["Town Central", "Toon Town Central"]
        case .donaldsDock: ["Donald's Dock"]
        case .daisyGardens: ["Daisy Gardens"]
        case .minniesMelodyland: ["Minnie's Melodyland"]
        case .theBrrgh: ["The Brrgh"]
        case .donaldsDreamland: ["Donald's Dreamland"]
        }
    }
}

struct CogStreetQuestion: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "playground and cog")
    static let defaultQuery = CogStreetQuestionQuery()
    let id: String
    let playground: Playground
    let cog: CogType

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(playground.neighborhoodName) for \(cog.spokenName)")
    }
    static var all: [CogStreetQuestion] {
        Playground.allCases.flatMap { place in
            CogType.allCases.map { cog in
                CogStreetQuestion(id: "\(place.rawValue)-\(cog.rawValue)", playground: place, cog: cog)
            }
        }
    }
}

struct CogStreetQuestionQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [CogStreetQuestion] {
        CogStreetQuestion.all.filter { identifiers.contains($0.id) }
    }
    func suggestedEntities() async throws -> [CogStreetQuestion] { CogStreetQuestion.all }
    func entities(matching string: String) async throws -> [CogStreetQuestion] {
        let query = string.localizedLowercase
        return CogStreetQuestion.all.filter { question in
            let placeMatches = question.playground.spokenAliases.contains { query.contains($0.localizedLowercase) }
                || query.contains(question.playground.neighborhoodName.localizedLowercase)
            let cogMatches = question.cog.spokenAliases.contains { query.contains($0.localizedLowercase) }
            return placeMatches && cogMatches
        }
    }
}

struct StreetRanking {
    let streets: [Street]
    let percentage: Int

    static func bestStreet(in neighborhood: Neighborhood, for cog: CogType) -> StreetRanking? {
        let eligible = neighborhood.streets.compactMap { street -> (Street, Int)? in
            guard let value = cog.percentage(in: street) else { return nil }
            return (street, value)
        }
        guard let highest = eligible.map(\.1).max() else { return nil }
        return StreetRanking(streets: eligible.filter { $0.1 == highest }.map(\.0), percentage: highest)
    }
}

struct BestStreetIntent: AppIntent {
    static var title: LocalizedStringResource = "Find Best Cog Street"
    static var description = IntentDescription("Finds the street with the highest percentage for a cog type in a playground.")
    @Parameter(title: "Playground and cog") var question: CogStreetQuestion
    static var parameterSummary: some ParameterSummary { Summary("Find the best street for \(\.$question)") }

    func spokenResponse(neighborhoods: [Neighborhood] = Neighborhood.all) -> String {
        guard let neighborhood = neighborhoods.first(where: { $0.name == question.playground.neighborhoodName }),
              let ranking = StreetRanking.bestStreet(in: neighborhood, for: question.cog) else {
            return "I couldn't find a \(question.cog.spokenName) percentage for \(question.playground.neighborhoodName)."
        }
        let names = ranking.streets.map(\.name).joined(separator: ", ")
        let verb = ranking.streets.count == 1 ? "has" : "share"
        return "\(names) \(verb) the highest \(question.cog.spokenName) percentage in \(question.playground.neighborhoodName), at \(ranking.percentage) percent."
    }

    func perform() async throws -> some IntentResult {
        .result(dialog: IntentDialog(stringLiteral: spokenResponse()))
    }
}

struct TTRAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: BestStreetIntent(),
            phrases: [
                "Find the best cog street with \(.applicationName)",
                "Find the best coke street with \(.applicationName)",
                "Ask \(.applicationName) for the best cog street",
                "What's the best street in \(\.$question) in \(.applicationName)",
                "What's the best street in \(\.$question) and \(.applicationName)",
                "Which street has the highest cog percentage for \(\.$question) in \(.applicationName)"
            ],
            shortTitle: "Best Cog Street",
            systemImageName: "chart.bar.fill"
        )
    }
}
