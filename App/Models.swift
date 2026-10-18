import Foundation

enum LabAccount: String, CaseIterable, Identifiable {
    case expiredPro = "Учебный PRO"
    case basic = "Базовый пользователь"
    case suspended = "Заблокированный PRO"
    var id: String { rawValue }

    var accountEnabled: Int32 { self == .suspended ? 0 : 1 }
    var planCode: Int32 { self == .basic ? 0 : 2 }
}

enum LicenseMode: String, CaseIterable, Identifiable {
    case local = "Локальная проверка"
    case simulatedServer = "Имитация сервера"
    var id: String { rawValue }
}

struct LicenseCheck: Identifiable {
    let id: String
    let passed: Bool
    let explanation: String
}

struct LicenseSnapshot {
    let accessGranted: Bool
    let expiryText: String
    let sourceDescription: String
    let checks: [LicenseCheck]
}

struct Course: Identifiable {
    let id: Int
    let name: String
    let category: String
    let duration: String
    let isPremium: Bool
    let description: String
    let article: String
}

enum Catalog {
    static let courses: [Course] = [
        .init(id: 1, name: "Структура звука", category: "Аудио", duration: "12 мин", isPremium: false,
              description: "Слушаем и разбираем отдельные слои композиции.",
              article: "Звук складывается из частоты, амплитуды и спектральных составляющих. Здесь могла бы быть полноценная лекция с упражнениями."),
        .init(id: 2, name: "Основы памяти", category: "Технологии", duration: "15 мин", isPremium: false,
              description: "От адреса до содержимого ячейки.",
              article: "Данные и инструкции могут находиться в разных сегментах исполняемого файла. Адрес и смещение — не одно и то же."),
        .init(id: 3, name: "Архитектура ARM64", category: "Технологии", duration: "32 мин", isPremium: true,
              description: "Регистры, инструкции, условные переходы.",
              article: "В AArch64 аргументы часто передаются через X0–X7. Условные ветвления зависят от флагов процессора."),
        .init(id: 4, name: "Дизассемблирование", category: "Технологии", duration: "41 мин", isPremium: true,
              description: "Читаем машинные инструкции через IDA.",
              article: "При анализе полезны сегменты, строки, Xrefs, графы потока управления и псевдокод."),
        .init(id: 5, name: "Разбор транзакций", category: "Разработка", duration: "26 мин", isPremium: true,
              description: "От продукта до права доступа.",
              article: "Покупка, проверенная транзакция и право доступа — разные сущности. В реальном приложении серверная проверка может быть решающей."),
        .init(id: 6, name: "Архив заметок", category: "Организация", duration: "18 мин", isPremium: false,
              description: "Создание личной базы знаний.",
              article: "Разбивайте заметки на сущности, связи и метаданные, чтобы их можно было быстро находить."),
        .init(id: 7, name: "Профилирование", category: "Разработка", duration: "39 мин", isPremium: true,
              description: "Измеряем производительность приложения.",
              article: "Следует разделять сетевую задержку, вычислительную нагрузку и отображение интерфейса."),
        .init(id: 8, name: "Экспорт коллекций", category: "Организация", duration: "24 мин", isPremium: true,
              description: "Подготавливаем архив для выгрузки.",
              article: "Этот раздел представляет учебную PRO-функцию. Сами данные намеренно демонстрационные.")
    ]
}
