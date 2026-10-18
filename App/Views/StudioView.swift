import SwiftUI
import AtlasPolicy
import AtlasSignals

struct AtlasStudioView: View {
    @EnvironmentObject var model: AtlasCoordinator
    @State private var input = "Цифровая подпись подтверждает происхождение данных. Однако это не доказывает, что срок доступа ещё действует. Надёжная система проверяет несколько независимых условий."
    @State private var hasAnalyzed = false
    private var metrics: AtlasTextMetrics { AtlasTextAnalyzer.analyze(input) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AtlasTitle(title: "Текстовая студия", subtitle: "Работающий инструмент, а не имитация ИИ")
                AtlasSurface {
                    VStack(alignment: .leading, spacing: 11) {
                        Text("Входной текст").font(.headline)
                        TextEditor(text: $input).frame(height: 155)
                            .scrollContentBackground(.hidden)
                            .padding(7)
                            .background(Color.atlasSand, in: RoundedRectangle(cornerRadius: 12))
                        Button {
                            model.refreshLocalDecisions()
                            hasAnalyzed = model.can(.studio)
                            model.record("studio", hasAnalyzed ? "processed \(input.count) characters" : "denied")
                        } label: {
                            Label("Анализировать", systemImage: "waveform.path")
                                .frame(maxWidth: .infinity)
                        }.buttonStyle(.borderedProminent).tint(Color.atlasBlue)
                    }
                }
                if hasAnalyzed && model.can(.studio) {
                    AtlasSurface {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Результат").font(.headline)
                            HStack(spacing: 8) {
                                metricBox("Слова", "\(metrics.words)")
                                metricBox("Фразы", "\(metrics.sentences)")
                                metricBox("Разнообразие", String(format: "%.0f%%", metrics.diversity * 100))
                            }
                            Divider()
                            Text("Частотные термины").font(.subheadline.bold())
                            ForEach(0..<metrics.topTerms.count, id: \.self) { index in
                                HStack {
                                    Text(metrics.topTerms[index].0).font(.subheadline)
                                    Spacer()
                                    Text("\(metrics.topTerms[index].1)").foregroundStyle(.secondary).monospacedDigit()
                                }
                            }
                        }
                    }
                    if model.can(.exporting) {
                        ShareLink(item: "Atlas Studio • слов: \(metrics.words), предложений: \(metrics.sentences), уникальных: \(metrics.uniqueWords)") {
                            Label("Поделиться отчётом", systemImage: "square.and.arrow.up")
                        }.buttonStyle(.bordered)
                    }
                } else if !model.can(.studio) {
                    AtlasSurface {
                        VStack(alignment: .leading, spacing: 8) {
                            AtlasGateBadge(allowed: false)
                            ForEach(model.reasons(.studio), id: \.self) { reason in
                                Text("• \(reason)").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }.padding(16)
        }
        .background(Color.atlasSand)
        .navigationTitle("Студия")
    }

    private func metricBox(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold()).foregroundStyle(Color.atlasBlue)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.atlasSand, in: RoundedRectangle(cornerRadius: 12))
    }
}
