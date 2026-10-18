import SwiftUI

private extension View {
    func labCard() -> some View {
        self.padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HomeView: View {
    @EnvironmentObject private var license: LicenseManager
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ATLAS / LAB").font(.caption.bold()).tracking(3).foregroundStyle(.secondary)
                        Text("Исследуй идеи.\nОткрывай возможности.")
                            .font(.largeTitle.bold())
                        Text("Учебное приложение с многоуровневой моделью доступа.")
                            .foregroundStyle(.secondary)
                        HStack {
                            Label(license.snapshot.accessGranted ? "PRO активен" : "PRO недоступен",
                                  systemImage: license.snapshot.accessGranted ? "checkmark.seal.fill" : "lock.shield")
                                .font(.subheadline.bold())
                            Spacer()
                            Text(license.mode == .local ? "LOCAL" : "JSON MOCK")
                                .font(.caption.monospaced())
                        }
                        .padding(12)
                        .background(.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(22)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    HStack(spacing: 12) {
                        metric(value: "8", name: "лекций", icon: "books.vertical")
                        metric(value: "5", name: "PRO-уровня", icon: "star.circle")
                    }
                    Text("Рекомендуемое").font(.title2.bold())
                    ForEach(Array(Catalog.courses.prefix(3))) { item in
                        NavigationLink(destination: CourseDetailView(course: item)) {
                            HStack(spacing: 12) {
                                Image(systemName: item.isPremium ? "sparkles.rectangle.stack" : "text.book.closed")
                                    .font(.title2).frame(width: 38)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(item.name).font(.headline)
                                    Text(item.description).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if item.isPremium { Image(systemName: "lock.fill").foregroundStyle(.orange) }
                            }
                            .labCard()
                        }.buttonStyle(.plain)
                    }
                }.padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Главная")
        }
    }

    private func metric(value: String, name: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(.indigo)
            Text(value).font(.title.bold())
            Text(name).font(.caption).foregroundStyle(.secondary)
        }.labCard()
    }
}

struct LibraryView: View {
    @EnvironmentObject private var license: LicenseManager
    var body: some View {
        NavigationStack {
            List(Catalog.courses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    HStack(spacing: 12) {
                        Image(systemName: course.isPremium ? "lock.rectangle" : "book")
                            .font(.title2).foregroundStyle(course.isPremium ? Color.indigo : Color.secondary)
                            .frame(width: 38)
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(course.name).font(.headline)
                                if course.isPremium { Text("PRO").font(.caption2.bold()).foregroundStyle(.orange) }
                            }
                            Text("\(course.category) · \(course.duration)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }.padding(.vertical, 5)
                }
            }
            .navigationTitle("Библиотека")
        }
    }
}

struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject private var license: LicenseManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: "waveform.path.ecg.rectangle")
                    .font(.system(size: 70)).frame(maxWidth: .infinity)
                    .foregroundStyle(.indigo).padding(.vertical, 26)
                Text(course.category.uppercased()).font(.caption.bold()).foregroundStyle(.secondary)
                Text(course.name).font(.largeTitle.bold())
                Text(course.description).foregroundStyle(.secondary)
                Divider()
                if !course.isPremium || license.snapshot.accessGranted {
                    Label("Материал доступен", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                    Text(course.article).font(.body).lineSpacing(6)
                    Text("Время: \(course.duration)").font(.footnote).foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Доступно с PRO", systemImage: "lock.fill").font(.title3.bold())
                        Text("Эта лекция закрыта: итоговая проверка лицензии не пройдена.")
                        Text("Перейди на вкладку «Подписка», чтобы посмотреть каждое условие проверки.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }.labCard()
                }
            }.padding(20)
        }.navigationTitle("Лекция").navigationBarTitleDisplayMode(.inline)
    }
}

struct ReportsView: View {
    @EnvironmentObject private var license: LicenseManager
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Прогресс изучения").font(.title2.bold())
                    HStack {
                        Label("2 завершены", systemImage: "checkmark.circle")
                        Spacer()
                        Text("25%").bold()
                    }.labCard()
                    Text("Расширенная аналитика").font(.title2.bold())
                    if license.snapshot.accessGranted {
                        VStack(alignment: .leading, spacing: 16) {
                            statBar("Технологии", 0.8)
                            statBar("Аудио", 0.42)
                            statBar("Разработка", 0.55)
                            Text("PRO-отчёт сформирован из демонстрационных данных.")
                                .font(.caption).foregroundStyle(.secondary)
                        }.labCard()
                    } else {
                        Label("Подробные графики доступны только с PRO", systemImage: "lock.fill")
                            .foregroundStyle(.secondary).labCard()
                    }
                }.padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Аналитика")
        }
    }
    private func statBar(_ name: String, _ value: Double) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(name).font(.subheadline)
            ProgressView(value: value).tint(.indigo)
        }
    }
}

struct AccountView: View {
    @EnvironmentObject private var license: LicenseManager
    @State private var storeKitResult = "StoreKit пока не проверялся"
    @State private var isInspecting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Демо-профиль") {
                    Picker("Пользователь", selection: $license.account) {
                        ForEach(LabAccount.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("Способ проверки", selection: $license.mode) {
                        ForEach(LicenseMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                }
                Section("Статус") {
                    Label(license.snapshot.accessGranted ? "PRO АКТИВЕН" : "PRO НЕАКТИВЕН",
                          systemImage: license.snapshot.accessGranted ? "checkmark.seal.fill" : "xmark.shield")
                        .foregroundStyle(license.snapshot.accessGranted ? .green : .red)
                    LabeledContent("Истекает", value: license.snapshot.expiryText)
                    Text(license.snapshot.sourceDescription)
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("Подробная диагностика") {
                    ForEach(license.snapshot.checks) { item in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: item.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(item.passed ? .green : .orange)
                            Text(item.explanation)
                            Spacer(minLength: 4)
                        }
                    }
                }
                Section("StoreKit 2 — настоящий API") {
                    Button(isInspecting ? "Проверка…" : "Проверить продукты и права") {
                        isInspecting = true
                        Task {
                            storeKitResult = await StoreKitInspector.diagnostic()
                            isInspecting = false
                        }
                    }.disabled(isInspecting)
                    Text(storeKitResult).font(.footnote).foregroundStyle(.secondary)
                    Text("В приложении нет реальных платных товаров. Это исследование API без списания денег.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("Исследовательский маркер") {
                    Text(String(cString: lab_license_marker()))
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("Подписка")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { license.refresh() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
        }
    }
}
