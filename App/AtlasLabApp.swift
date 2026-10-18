import SwiftUI

@main
struct AtlasLabApp: App {
    @StateObject private var license = LicenseManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(license)
                .tint(.indigo)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Главная", systemImage: "house.fill") }
            LibraryView()
                .tabItem { Label("Библиотека", systemImage: "books.vertical") }
            ReportsView()
                .tabItem { Label("Аналитика", systemImage: "chart.bar.xaxis") }
            AccountView()
                .tabItem { Label("Подписка", systemImage: "person.crop.circle") }
        }
    }
}
