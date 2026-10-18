import SwiftUI
import AtlasPolicy

struct AtlasLabView: View {
    @EnvironmentObject var model: AtlasCoordinator
    @State private var showReset = false
    @StateObject private var storeKit = AtlasStoreKitInspector()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AtlasTitle(title: "Лаборатория", subtitle: "Три движка, подписи Ed25519, тестовый API и история решений")

                AtlasSurface {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Профиль").font(.headline)
                        Picker("Аккаунт", selection: Binding(get: { model.settings.profileID }, set: { model.updateProfile($0) })) {
                            ForEach(model.profiles) { profile in
                                Text(profile.displayName).tag(profile.id)
                            }
                        }.pickerStyle(.menu)
                        Text(model.selectedProfile?.caption ?? "").font(.caption).foregroundStyle(.secondary)
                        Divider()
                        Text("Источник прав").font(.headline)
                        Picker("Проверка", selection: Binding(get: { model.mode }, set: { model.updateMode($0) })) {
                            ForEach(AtlasEvaluationMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }.pickerStyle(.menu)
                        Text("Локальный: нативный C. Подписанный: Ed25519. Комбинированный: оба одновременно.")
                            .font(.caption).foregroundStyle(.secondary)
                        Divider()
                        Text("Учебный сервер (необязательно)").font(.headline)
                        TextField("http://192.168.1.20:8765", text: Binding(get: { model.settings.serverURL }, set: { model.updateServerURL($0) }))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .font(.footnote.monospaced())
                            .padding(10).background(Color.atlasSand, in: RoundedRectangle(cornerRadius: 10))
                        Text("Если оставить пустым, используется подписанный ответ, включённый в приложение.")
                            .font(.caption).foregroundStyle(.secondary)
                        Button {
                            Task { await model.refreshProof() }
                        } label: {
                            if model.busy { ProgressView() }
                            else { Label("Перепроверить доступ", systemImage: "arrow.clockwise.shield") }
                        }.buttonStyle(.borderedProminent).disabled(model.busy)
                        Text(model.statusLine).font(.caption).foregroundStyle(.secondary)
                    }
                }

                AtlasSurface {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Результаты политики").font(.headline)
                        ForEach(AtlasFeature.allCases) { feature in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Label(feature.title, systemImage: feature.icon).font(.subheadline.bold())
                                    Spacer()
                                    AtlasGateBadge(allowed: model.can(feature))
                                }
                                ForEach(model.reasons(feature), id: \.self) { reason in
                                    Text("· \(reason)").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            if feature != AtlasFeature.allCases.last { Divider() }
                        }
                    }
                }

                AtlasSurface {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Техническая диагностика").font(.headline)
                        ForEach(0..<model.diagnostics.count, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text(model.diagnostics[index].0).foregroundStyle(.secondary)
                                Spacer(minLength: 8)
                                Text(model.diagnostics[index].1).multilineTextAlignment(.trailing).textSelection(.enabled)
                            }.font(.caption)
                        }
                    }
                }

                AtlasSurface {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Настоящий StoreKit 2 (только чтение)").font(.headline)
                        Button {
                            Task { await storeKit.inspect() }
                        } label: {
                            Label("Прочитать currentEntitlements", systemImage: "checkmark.shield")
                        }.buttonStyle(.bordered).disabled(storeKit.busy)
                        ForEach(storeKit.lines, id: \.self) { line in
                            Text(line).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                AtlasSurface {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Журнал решений").font(.headline)
                            Spacer()
                            AtlasPill(text: model.ledgerValid ? "Цепочка цела" : "Ошибка", tint: model.ledgerValid ? .atlasTeal : .orange)
                        }
                        ForEach(model.audit.prefix(20)) { entry in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(entry.action) · \(entry.timestamp.formatted(date: .omitted, time: .standard))")
                                    .font(.caption.bold())
                                Text(entry.detail).font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        Button(role: .destructive) { showReset = true } label: {
                            Label("Сбросить данные эксперимента", systemImage: "arrow.counterclockwise")
                        }.font(.caption)
                    }
                }
            }.padding(16)
        }
        .background(Color.atlasSand)
        .navigationTitle("Лаборатория")
        .confirmationDialog("Удалить локальный прогресс?", isPresented: $showReset) {
            Button("Сбросить", role: .destructive) { model.reset() }
        }
    }
}
