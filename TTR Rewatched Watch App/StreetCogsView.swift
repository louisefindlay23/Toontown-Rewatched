import SwiftUI

// Neighborhood Data Format
struct Neighborhood: Identifiable {
    let id = UUID()
    let name: String
    let streets: [Street]
}

// Street Data Format
struct Street: Identifiable {
    let id = UUID()
    let name: String
    let cogPercentages: CogPercentage
}

class SelectedStreet: ObservableObject {
    @Published var street: Street?
}

// Cog (Enemy) Percentages Data Format
struct CogPercentage {
    let bossbot: Int
    let lawbot: Int
    let cashbot: Int
    let sellbot: Int
}

// List all Neighborhoods in order
struct NeighborhoodView: View {
    // Street Cog Data - confirmed in-game
    let neighborhoods = [
        Neighborhood(
            name: "Toontown Central",
            streets: [
                Street(name: "Punchline Place", cogPercentages: CogPercentage(bossbot: 10, lawbot: 10, cashbot: 40, sellbot: 40)),
                Street(name: "Silly Street", cogPercentages: CogPercentage(bossbot: 25, lawbot: 25, cashbot: 25, sellbot: 25)),
                Street(name: "Loopy Lane", cogPercentages: CogPercentage(bossbot: 10, lawbot: 70, cashbot: 10, sellbot: 10))
            ]
        ),
        Neighborhood(
            name: "Donald's Dock",
            streets: [
                Street(name: "Barnacle Boulevard", cogPercentages: CogPercentage(bossbot: 90, lawbot: 10, cashbot: 0, sellbot: 0)),
                Street(name: "Seaweed Street", cogPercentages: CogPercentage(bossbot: 0, lawbot: 0, cashbot: 90, sellbot: 10)),
                Street(name: "Lighthouse Lane", cogPercentages: CogPercentage(bossbot: 40, lawbot: 40, cashbot: 10, sellbot: 10))
            ]
        ),
        Neighborhood(
            name: "Daisy Gardens",
            streets: [
                Street(name: "Elm Street", cogPercentages: CogPercentage(bossbot: 0, lawbot: 20, cashbot: 10, sellbot: 70)),
                Street(name: "Maple Street", cogPercentages: CogPercentage(bossbot: 10, lawbot: 70, cashbot: 0, sellbot: 20)),
                Street(name: "Oak Street", cogPercentages: CogPercentage(bossbot: 5, lawbot: 5, cashbot: 5, sellbot: 85))
            ]
        ),
        Neighborhood(
            name: "Minnie's Melodyland",
            streets: [
                Street(name: "Alto Avenue", cogPercentages: CogPercentage(bossbot: 0, lawbot: 0, cashbot: 50, sellbot: 50)),
                Street(name: "Baritone Boulevard", cogPercentages: CogPercentage(bossbot: 0, lawbot: 0, cashbot: 90, sellbot: 10)),
                Street(name: "Tenor Terrace", cogPercentages: CogPercentage(bossbot: 50, lawbot: 50, cashbot: 0, sellbot: 0))
            ]
        ),
        Neighborhood(
            name: "The Brrgh",
            streets: [
                Street(name: "Walrus Way", cogPercentages: CogPercentage(bossbot: 90, lawbot: 10, cashbot: 0, sellbot: 0)),
                Street(name: "Sleet Street", cogPercentages: CogPercentage(bossbot: 10, lawbot: 20, cashbot: 30, sellbot: 40)),
                Street(name: "Polar Place", cogPercentages: CogPercentage(bossbot: 5, lawbot: 85, cashbot: 5, sellbot: 5))
            ]
        ),
        Neighborhood(
            name: "Donald's Dreamland",
            streets: [
                Street(name: "Lullaby Lane", cogPercentages: CogPercentage(bossbot: 25, lawbot: 25, cashbot: 25, sellbot: 25)),
                Street(name: "Pajama Place", cogPercentages: CogPercentage(bossbot: 5, lawbot: 5, cashbot: 85, sellbot: 5))
            ]
        )
    ]
    
    @State private var selectedNeighborhood: Neighborhood?
        @StateObject private var selectedStreet = SelectedStreet()
        @State private var isSheetPresented = false

        var body: some View {
            NavigationView {
                ScrollView {
                    VStack {
                        // Lists all neighborhoods
                        ForEach(neighborhoods, id: \.name) { neighborhood in
                            Button(action: {
                                selectedNeighborhood = neighborhood
                                selectedStreet.street = nil
                            }) {
                                Text(neighborhood.name)
                            }
                            .sheet(item: $selectedNeighborhood) { _ in
                                StreetView(neighborhood: selectedNeighborhood, selectedStreet: selectedStreet)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Neighborhoods")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }

// Lists all streets in a neighborhood
struct StreetView: View {
    let neighborhood: Neighborhood?
    @ObservedObject var selectedStreet: SelectedStreet

    var body: some View {
        ScrollView {
            VStack {
                if let neighborhood = neighborhood {
                    ForEach(neighborhood.streets) { street in
                        Button(action: {
                            selectedStreet.street = street
                        }) {
                            Text(street.name)
                        }
                        .sheet(item: $selectedStreet.street) { selected in
                            if let selectedStreet = selectedStreet.street, selectedStreet.id == selected.id {
                                CogPercentageSheet(streetName: selected.name, percentage: selected.cogPercentages)
                            }
                        }
                        .id(street.id)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(neighborhood?.name ?? "")
    }
}

// Show cog percentage for a street
struct CogPercentageSheet: View {
    let streetName: String
    let percentage: CogPercentage
    
    var body: some View {
        VStack {
            Text("\(streetName)")
                .bold()
                .padding(.bottom, 10)
            Spacer()
            Text("Bossbots: \(percentage.bossbot)%")
            Spacer()
            Text("Lawbots: \(percentage.lawbot)%")
            Spacer()
            Text("Cashbots: \(percentage.cashbot)%")
            Spacer()
            Text("Sellbots: \(percentage.sellbot)%")
            Spacer()
        }
        .padding()
    }
}

struct StreetCogsView_Previews: PreviewProvider {
    static var previews: some View {
        NeighborhoodView()
    }
}
