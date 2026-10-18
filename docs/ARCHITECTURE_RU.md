# Архитектура Atlas Lab X

| Компонент | Содержимое | Что видно в IDA |
|---|---|---|
| `AtlasLabX` | SwiftUI, нативный C, хранилище, сетевой клиент, StoreKit 2 (read-only) | UI / вызовы локальной проверки / цепочка принятия решения |
| `AtlasPolicy.framework` | Модель tier/features/rights, движок правил, Ed25519-верификатор | Swift, CryptoKit, сериализация, policy engine |
| `AtlasSignals.framework` | Локальная аналитика, SHA-256 хеш-цепочка журнала | Swift / CryptoKit / строки аудита |
| `server/app.py` | Отдельный HTTP-сервис, выдающий права | **Не находится в IPA**; серверные решения изменить редактированием IPA нельзя |
| `server/accounts.json` | Источник прав для тестового HTTP API | Исходные данные на сервере |
| `App/Resources/SignedFixtures.json` | Подписанные офлайн-ответы | Клиент получает подлинные подписи без подключения сервера |

**Проверки:**
- Native C: integrity seal, account flags, tier, feature bits, local expiry.
- Swift rule engine: policy enablement, tier, revision, feature list, state, expiry, lease freshness.
- Signed response: Ed25519 signature, account binding, nonce binding, timestamp and lease check.
- Hybrid: требует прохождения и локальной, и подписанной ветки.

В текущей лаборатории приватный ключ из `server/dev-private-key.pem` находится **только среди серверных исходников**, не в приложении. Все ключи, аккаунты и данные демонстрационные. Это не продукционная система защиты от модификаций.
