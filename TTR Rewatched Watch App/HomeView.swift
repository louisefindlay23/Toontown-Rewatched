import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    NavigationLink {
                        InvasionsView()
                    } label: {
                        Image(systemName: "gear")
                        Text("Invasions")
                    }
                    Spacer()
                    NavigationLink {
                        FieldOfficesView()
                    } label: {
                        Image(systemName: "briefcase")
                        Text("Field Offices")
                    }
                    NavigationLink {
                        NeighborhoodView()
                    } label: {
                        Image(systemName: "map")
                        Text("Street Cogs")
                    }
                    NavigationLink {
                        SiriDiagnosticsView()
                    } label: {
                        Image(systemName: "waveform")
                        Text("Siri Diagnostics")
                    }
                    Spacer()
                }
                    .navigationBarTitle("TTR Rewatched")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct SiriDiagnosticsView: View {
    @AppStorage("latestSiriEntityMatches") private var entityMatches = "No lookup recorded"
    @AppStorage("latestSiriIntentQuestion") private var intentQuestion = "No intent call recorded"
    @AppStorage("latestSiriIntentAnswer") private var intentAnswer = "No answer recorded"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                diagnosticRow(title: "Entity Match", value: entityMatches)
                diagnosticRow(title: "Intent Question", value: intentQuestion)
                diagnosticRow(title: "Returned Answer", value: intentAnswer)
            }
            .padding()
        }
        .navigationTitle("Siri Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func diagnosticRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(value).font(.body)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
