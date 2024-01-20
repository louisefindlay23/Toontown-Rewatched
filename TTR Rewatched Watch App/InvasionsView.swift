import SwiftUI
import Combine

// Invasion Details Format
class ObservableInvasionDetails: ObservableObject {
    @Published var asOf: Int
    @Published var type: String
    @Published var progress: String
    
    init(asOf: Int, type: String, progress: String) {
        self.asOf = asOf
        self.type = type
        self.progress = progress
    }
}

struct IdentifiableInvasionsString: Identifiable {
    var id: String { stringValue }
    let stringValue: String
}

// Location Name from Invasions API Key
struct InvasionLocationWrapper: Identifiable {
    let id = UUID()
    let locationName: String
}

// Convert Unix timestamp format to HH:mm
func formattedInvasionTime(from timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}

// List all invasions by type - enemy name
struct InvasionsView: View {
    @StateObject var viewModel = InvasionsViewModel()
    // Stores invasion tapped on to open InvasionDetailsView
    @State private var selectedInvasion: IdentifiableInvasionsString? = nil
    @State private var showRefreshButton = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Lists all invasions
                    ForEach(viewModel.invasionDetails.sorted(by: { $0.key < $1.key }), id: \.key) { locationName, details in
                        Button(action: {
                            selectedInvasion = IdentifiableInvasionsString(stringValue: locationName)
                        }) {
                            Text(details.type)
                        }
                    }
                    // Opens InvasionDetailsView
                    .sheet(item: $selectedInvasion) { locationName in
                        if let details = viewModel.invasionDetails[locationName.stringValue] {
                            InvasionsDetailsView(invasion: details, locationName: locationName.stringValue, viewModel: viewModel)
                        }
                    }
                    
                    Spacer()
                    // Shows loading screen when API data first loads
                    VStack {
                        HStack {
                            Spacer()
                            if let lastUpdated = viewModel.invasionData?.lastUpdated {
                                Text("Updated \(formattedInvasionTime(from: lastUpdated))")
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                            } else {
                                Text("Invasions loading")
                            }
                            Spacer()
                        }
                        // Shows refresh button after API data first loads
                        if showRefreshButton {
                            Button(action: {
                                viewModel.fetchInvasions {
                                    showRefreshButton = true
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchInvasions {
                    showRefreshButton = true
                }
            }
            .navigationBarTitle("Invasions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

// Lists details for a specific invasion
struct InvasionsDetailsView: View {
    @ObservedObject var invasion: ObservableInvasionDetails
    let locationName: String
    let viewModel: InvasionsViewModel

    var body: some View {
        VStack {
            Spacer()
            Text("\(invasion.type)s")
            Spacer()
            Text("In \(locationName)")
            Spacer()
            Text("\(invasion.progress) Defeated")
            Spacer()
            Text("Updated \(formattedInvasionTime(from: invasion.asOf))")
            Spacer()
                .padding(.top, 5)
            Button(action: {
                viewModel.fetchInvasions{}
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(Color.white)
            }
        }
    }
}

class InvasionsViewModel: ObservableObject {
    @Published var invasionDetails: [String: ObservableInvasionDetails] = [:]
    @Published var invasionData: InvasionData?
    
    // Calls Invasions API
    func fetchInvasions(completion: @escaping () -> Void) {
        
        guard let url = URL(string: "https://www.toontownrewritten.com/api/invasions") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        // Set cache to no-cache to ensure API data is current
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        // Set descriptive user agent per API guidelines
        request.setValue("TTR Rewatched watchOS App", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: InvasionData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error decoding data: \(error)")
                }
            }, receiveValue: { decodedResponse in
                self.invasionData = decodedResponse
                self.invasionDetails = decodedResponse.invasions.mapValues {
                    ObservableInvasionDetails(asOf: $0.asOf, type: $0.type, progress: $0.progress)
                }
                completion()
            })
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

struct InvasionsView_Previews: PreviewProvider {
    static var previews: some View {
        InvasionsView()
    }
}

struct InvasionDetails: Codable {
    let asOf: Int
    let type: String
    let progress: String
}

struct InvasionData: Codable {
    let error: String?
    let invasions: [String: InvasionDetails]
    let lastUpdated: Int
}
