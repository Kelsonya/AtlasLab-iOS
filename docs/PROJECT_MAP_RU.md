# Как устроено Atlas Lab

```text
AtlasLabApp.swift       → запуск приложения и вкладки
Views.swift             → интерфейс, закрытые и открытые экраны
Models.swift            → тарифы, тестовые аккаунты, каталог материалов
LicenseManager.swift    → логика принятия решения о PRO-доступе
LicenseCore.c           → нативная функция проверки в ARM64 Mach-O
LicenseCore.h           → интерфейс между Swift и C
StoreKitInspector.swift → чтение настоящего API StoreKit 2 (без покупок)
RemoteFixture.json      → симуляция ответа сервера (без сети)
```

## Локальный путь

```text
Экран "Подписка"
      ↓
LicenseManager.refresh()
      ↓
LicenseEvaluator.evaluate()
      ↓
lab_license_seed_expiry()  ← именно эту строку ищем в IDA
      ↓
ISO8601DateFormatter      ← преобразуем строку в дату
      ↓
lab_has_local_entitlement(account, plan, expiry, now)
      ↓
accessGranted
      ↓
Закрытые лекции и расширенная аналитика
```

## Имитация серверного пути

```text
LicenseEvaluator.evaluate()
      ↓
RemoteFixture.json
      ↓
active && planCode == 2 && expiresAt > now
      ↓
accessGranted
```

Важное отличие: в этом режиме патч локального `lab_license_seed_expiry()` не влияет на `RemoteFixture.json`. Но это **локальный макет**, а не реальная серверная система.

## Учебные задания

- A: найти строку и её Xrefs в ARM64.
- B: понять три последовательные проверки.
- C: изменить дату 2023 → 2099 в собственном бинарнике и проверить результат.
- D: сравнить поведение другого аккаунта, в котором проверка даты — не единственное условие.
- E: понять отличие StoreKit 2 от собственного макета лицензирования.
