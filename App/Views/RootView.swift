import SwiftUI
import AtlasPolicy

struct AtlasRootView: View {
    @EnvironmentObject var model: AtlasCoordinator
    var body: some View {
        TabView {
            NavigationStack { AtlasHomeView() }
                .tabItem { Label("Главная", systemImage: "square.grid.2x2") }
            NavigationStack { AtlasLibraryView() }
                .tabItem { Label("Библиотека", systemImage: "books.vertical") }
            NavigationStack { AtlasStudioView() }
                .tabItem { Label("Студия", systemImage: "wand.and.stars") }
            NavigationStack { AtlasInsightsView() }
                .tabItem { Label("Аналитика", systemImage: "chart.bar.fill") }
            NavigationStack { AtlasLabView() }
                .tabItem { Label("Лаборатория", systemImage: "waveform.path.ecg.rectangle") }
        }
        .tint(Color.atlasBlue)
    }
}

struct AtlasHomeView: View {
    @EnvironmentObject var model: AtlasCoordinator
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("ATLAS / X", systemImage: "atom")
                            .font(.caption.bold()).tracking(2)
                        Spacer()
                        Image(systemName: "sparkle.magnifyingglass")
                    }
                    .foregroundStyle(.white.opacity(0.85))
                    Text("Исследуй.\nСомневайся.\nДоказывай.")
                        .font(.system(size: 33, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Настоящая лаборатория проверки доступа с несколькими уровнями логики")
                        .foregroundStyle(.white.opacity(0.86)).font(.subheadline)
                    HStack(spacing: 12) {
                        Label(model.accountSummary, systemImage: "person.crop.circle")
                        Label(model.mode.label, systemImage: "square.stack.3d.up")
                    }.font(.caption.bold()).foregroundStyle(.white)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient(colors: [.atlasInk, .atlasBlue, .atlasViolet], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))

                AtlasTitle(title: "Модули доступа", subtitle: "Каждая функция проходит собственную цепочку проверок")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(AtlasFeature.allCases) { feature in
                        AtlasSurface {
                            VStack(alignment: .leading, spacing: 9) {
                                Image(systemName: feature.icon).font(.title2).foregroundStyle(Color.atlasBlue)
                                Text(feature.title).font(.subheadline.bold()).foregroundStyle(Color.atlasInk).lineLimit(2)
                                AtlasGateBadge(allowed: model.can(feature))
                            }.frame(maxWidth: .infinity, minHeight: 95, alignment: .leading)
                        }
                    }
                }
                AtlasSurface {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Прогресс лаборатории").font(.headline)
                        HStack {
                            Label("\(model.completed.count) из \(model.articles.count) материалов", systemImage: "checkmark.circle")
                            Spacer()
                            Label("\(model.openedCount) открытий", systemImage: "eye")
                        }.font(.caption).foregroundStyle(.secondary)
                        ProgressView(value: Double(model.completed.count), total: Double(max(model.articles.count, 1)))
                            .tint(Color.atlasTeal)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.atlasSand)
        .toolbar(.hidden, for: .navigationBar)
    }
}
