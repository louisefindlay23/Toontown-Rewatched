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
                    Spacer()
                }
                    .navigationBarTitle("TTR Rewatched")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
