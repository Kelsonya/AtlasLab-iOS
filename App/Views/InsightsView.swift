import SwiftUI
import Charts
import AtlasPolicy

struct AtlasInsightsView: View {
    @EnvironmentObject var model: AtlasCoordinator

    private struct MetricItem: Identifiable { let name: String; let value: Int; var id: String { name } }
    private var values: [MetricItem] {
        [MetricItem(name: "Просмотры", value: model.openedCount), MetricItem(name: "Отказы", value: model.deniedCount), MetricItem(name: "Завершено", value: model.completed.count), MetricItem(name: "Закладки", value: model.saved.count)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AtlasTitle(title: "Аналитика", subtitle: "Данные сохраняются локально между запусками")
                if model.can(.insights) {
                    AtlasSurface {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Активность лаборатории").font(.headline)
                            Chart(values) { item in
                                BarMark(x: .value("Событие", item.name), y: .value("Количество", item.value))
                                    .foregroundStyle(by: .value("Тип", item.name))
                                    .cornerRadius(6)
                            }.frame(height: 230)
                            Text("События подсчитываются приложением при фактическом открытии материалов и выполнении операций.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    AtlasSurface {
                        VStack(alignment: .leading, spacing: 9) {
                            Text("Исследовательские показатели").font(.headline)
                            LabeledContent("Открыто материалов", value: "\(model.openedCount)")
                            LabeledContent("Отклонённых запросов", value: "\(model.deniedCount)")
                            LabeledContent("Выполнено заданий", value: "\(model.completed.count)")
                            LabeledContent("Записей аудита", value: "\(model.audit.count)")
                        }
                    }
                } else {
                    AtlasSurface {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Аналитика требует активного тарифа", systemImage: "lock.fill").font(.headline)
                            ForEach(model.reasons(.insights), id: \.self) { reason in
                                Text(reason).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }.padding(16)
        }
        .background(Color.atlasSand)
        .navigationTitle("Аналитика")
    }
}
