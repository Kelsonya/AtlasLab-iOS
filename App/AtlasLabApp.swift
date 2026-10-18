import SwiftUI

@main
struct AtlasLabXApp: App {
    @StateObject private var coordinator = AtlasCoordinator()
    var body: some Scene {
        WindowGroup {
            AtlasRootView()
                .environmentObject(coordinator)
                .task { await coordinator.refreshProof() }
        }
    }
}
