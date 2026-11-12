import SwiftUI

@main
struct TTR_Rewatched_Watch_AppApp: App {
    init() {
        TTRAppShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
