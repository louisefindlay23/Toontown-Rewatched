import SwiftUI

class SelectedStreet: ObservableObject {
    @Published var street: Street?
}

// List all Neighborhoods in order
struct NeighborhoodView: View {
    // Street Cog Data - confirmed in-game
    let neighborhoods = Neighborhood.all
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
            Text("Bossbots: \(percentage.bossbot.map { "\($0)%" } ?? "—")")
            Spacer()
            Text("Lawbots: \(percentage.lawbot.map { "\($0)%" } ?? "—")")
            Spacer()
            Text("Cashbots: \(percentage.cashbot.map { "\($0)%" } ?? "—")")
            Spacer()
            Text("Sellbots: \(percentage.sellbot.map { "\($0)%" } ?? "—")")
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
