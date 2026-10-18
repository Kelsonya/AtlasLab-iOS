import SwiftUI
import AtlasPolicy

struct AtlasLibraryView: View {
    @EnvironmentObject var model: AtlasCoordinator
    @State private var search = ""
    @State private var onlySaved = false

    private var visible: [AtlasArticle] {
        model.articles.filter { article in
            let matching = search.isEmpty || article.title.localizedCaseInsensitiveContains(search) || article.summary.localizedCaseInsensitiveContains(search) || article.category.localizedCaseInsensitiveContains(search)
            return matching && (!onlySaved || model.saved.contains(article.id))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                AtlasTitle(title: "Библиотека", subtitle: "\(model.articles.count) материалов · поиск · закладки")
                Toggle("Только мои закладки", isOn: $onlySaved)
                    .font(.subheadline).tint(Color.atlasBlue)
                ForEach(visible) { article in
                    NavigationLink {
                        AtlasArticleView(article: article)
                    } label: {
                        AtlasSurface {
                            HStack(alignment: .top, spacing: 13) {
                                Image(systemName: article.symbol)
                                    .font(.title2).foregroundStyle(Color.atlasBlue)
                                    .frame(width: 42, height: 42)
                                    .background(Color.atlasBlue.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(article.category.uppercased()).font(.caption2.bold()).foregroundStyle(Color.atlasViolet)
                                    Text(article.title).font(.headline).foregroundStyle(Color.atlasInk).multilineTextAlignment(.leading)
                                    Text(article.summary).font(.caption).foregroundStyle(.secondary).lineLimit(2).multilineTextAlignment(.leading)
                                    HStack {
                                        Label("\(article.minutes) мин", systemImage: "clock")
                                        Spacer()
                                        AtlasGateBadge(allowed: model.can(article.feature))
                                    }.font(.caption2).foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
                            }
                        }
                    }.buttonStyle(.plain)
                }
            }.padding(16)
        }
        .background(Color.atlasSand)
        .searchable(text: $search, prompt: "Название, тема, описание")
        .navigationTitle("Библиотека")
    }
}

struct AtlasArticleView: View {
    @EnvironmentObject var model: AtlasCoordinator
    let article: AtlasArticle
    @State private var hasEntered = false
    @State private var permitted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Label(article.category, systemImage: article.symbol).font(.subheadline.bold()).foregroundStyle(Color.atlasBlue)
                Text(article.title).font(.system(size: 29, weight: .bold, design: .rounded))
                Text(article.summary).font(.subheadline).foregroundStyle(.secondary)
                if permitted {
                    Text(article.body).font(.body).lineSpacing(7).textSelection(.enabled)
                    Button {
                        model.markCompleted(article.id)
                    } label: {
                        Label(model.completed.contains(article.id) ? "Прочитано" : "Отметить прочитанным", systemImage: "checkmark.circle")
                    }.buttonStyle(.borderedProminent).tint(Color.atlasTeal)
                } else {
                    AtlasSurface {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Доступ ограничен", systemImage: "lock.shield").font(.headline).foregroundStyle(.orange)
                            Text("Это реальная проверка цепочки entitlement. Причины ниже получены из движка правил.")
                                .font(.subheadline).foregroundStyle(.secondary)
                            ForEach(model.reasons(article.feature), id: \.self) { reason in
                                Label(reason, systemImage: "exclamationmark.circle").font(.caption)
                            }
                        }
                    }
                }
            }.padding(20)
        }
        .background(Color.atlasSand)
        .navigationTitle("Материал")
        .toolbar {
            Button {
                model.toggleSaved(article.id)
            } label: {
                Image(systemName: model.saved.contains(article.id) ? "bookmark.fill" : "bookmark")
            }
        }
        .onAppear {
            if !hasEntered {
                hasEntered = true
                permitted = model.enter(article)
            }
        }
    }
}
