import SwiftUI
import Combine

// Field Office Details Format
class ObservableFieldOfficeDetails: ObservableObject {
    @Published var department: String
    @Published var difficulty: Int
    @Published var annexes: Int
    @Published var open: Bool
    
    init(department: String, difficulty: Int, annexes: Int, open: Bool) {
        self.department = department
        self.difficulty = difficulty
        self.annexes = annexes
        self.open = open
    }
}

struct IdentifiableFieldOfficesString: Identifiable {
    var id: String { stringValue }
    let stringValue: String
}

// Location Name from Field Offices API Key
struct FieldOfficeLocationWrapper: Identifiable {
    let id = UUID()
    let locationName: Int
}

// Convert locationName Zone IDs to strings
func matchFieldOfficeLocations(zoneID: Int) -> String {
    switch zoneID {
    case 3100: return "Walrus Way"
    case 3200: return "Sleet Street"
    case 3300: return "Polar Place"
    case 4100: return "Alto Avenue"
    case 4200: return "Baritone Boulevard"
    case 4300: return "Tenor Terrace"
    case 5100: return "Elm Street"
    case 5200: return "Maple Street"
    case 5300: return "Oak Street"
    case 9100: return "Lullaby Lane"
    case 9200: return "Pajama Place"
    default: return "Unknown Location"
    }
}

// Convert Unix timestamp format to HH:mm
func formattedFieldOfficeTime(from timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: date)
}

// List all Field Offices by difficulty
struct FieldOfficesView: View {
    @StateObject var viewModel = FieldOfficesViewModel()
    // Stores invasion tapped on to open InvasionDetailsView
    @State private var selectedFieldOffice: IdentifiableFieldOfficesString? = nil
    @State private var showRefreshButton = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Lists all field offices sorted by difficulty
                    ForEach(viewModel.fieldOfficeDetails.sorted(by: { $0.value.difficulty < $1.value.difficulty }), id: \.key) { locationName, details in
                        Button(action: {
                            selectedFieldOffice = IdentifiableFieldOfficesString(stringValue: locationName)
                        }) {
                            Text("\(details.difficulty + 1) Star")
                        }
                    }
                    .sheet(item: $selectedFieldOffice) { selectedOffice in
                        if let details = viewModel.fieldOfficeDetails[selectedOffice.stringValue] {
                            if let locationID = Int(selectedOffice.stringValue) {
                                FieldOfficeDetailsView(fieldOffice: details, locationName: locationID, viewModel: viewModel)
                            }
                        }
                    }
                    
                    Spacer()
                    // Shows loading screen when API data first loads
                    VStack {
                        HStack {
                            Spacer()
                            if let lastUpdated = viewModel.fieldOfficeData?.lastUpdated {
                                Text("Updated \(formattedFieldOfficeTime(from: lastUpdated))")
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                            } else {
                                Text("Field Offices loading")
                            }
                            Spacer()
                        }
                        // Shows refresh button after API data first loads
                        if showRefreshButton {
                            Button(action: {
                                viewModel.fetchFieldOffices {
                                    showRefreshButton = true
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                            }
                            .padding(.trailing)
                        }
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .onAppear {
                viewModel.fetchFieldOffices {
                    showRefreshButton = true
                }
            }
            .navigationBarTitle("Field Offices")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

// Lists details for a specific invasion
struct FieldOfficeDetailsView: View {
    @ObservedObject var fieldOffice: ObservableFieldOfficeDetails
    let locationName: Int
    let viewModel: FieldOfficesViewModel

    var body: some View {
        VStack {
            Spacer()
            Text("\(fieldOffice.difficulty + 1) Star Field Office")
            Spacer()
            Text("In \(matchFieldOfficeLocations(zoneID: locationName))")
            Spacer()
            Text("\(fieldOffice.annexes) Annexes Left")
            Spacer()
            if let lastUpdated = viewModel.fieldOfficeData?.lastUpdated {
                Text("Updated \(formattedFieldOfficeTime(from: lastUpdated))")
            } else {
                Text("")
            }
            Spacer()
                .padding(.top, 5)
            Button(action: {
                viewModel.fetchFieldOffices {}
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(Color.white)
            }
        }
    }
}

class FieldOfficesViewModel: ObservableObject {
    @Published var fieldOfficeDetails: [String: ObservableFieldOfficeDetails] = [:]
    @Published var fieldOfficeData: FieldOfficeData?
    
    // Calls Field Office API
    func fetchFieldOffices(completion: @escaping () -> Void) {
        
        guard let url = URL(string: "https://www.toontownrewritten.com/api/fieldoffices") else {
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
            .decode(type: FieldOfficeData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error decoding data: \(error)")
                }
            }, receiveValue: { decodedResponse in
                self.fieldOfficeData = decodedResponse
                self.fieldOfficeDetails = decodedResponse.fieldOffices.mapValues {
                    ObservableFieldOfficeDetails(department: $0.department, difficulty: $0.difficulty, annexes: $0.annexes, open: $0.open)
                }
                completion()
            })
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

struct FieldOfficesView_Previews: PreviewProvider {
    static var previews: some View {
        FieldOfficesView()
    }
}

struct FieldOfficeDetails: Codable {
    let department: String
    let difficulty: Int
    let annexes: Int
    let open: Bool
}

struct FieldOfficeData: Codable {
    let fieldOffices: [String: FieldOfficeDetails]
    let lastUpdated: Int
}
