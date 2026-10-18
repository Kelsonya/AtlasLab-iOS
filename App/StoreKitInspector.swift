import Foundation
import Combine
import StoreKit

@MainActor
final class AtlasStoreKitInspector: ObservableObject {
    @Published private(set) var lines: [String] = ["Проверка StoreKit ещё не запускалась"]
    @Published private(set) var busy = false

    func inspect() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        var output: [String] = []
        var count = 0
        for await result in Transaction.currentEntitlements {
            count += 1
            switch result {
            case .verified(let transaction):
                output.append("Проверена транзакция: \(transaction.productID)")
            case .unverified(let transaction, let error):
                output.append("Непроверенная транзакция \(transaction.productID): \(error.localizedDescription)")
            }
        }
        output.insert("Текущих StoreKit entitlements: \(count)", at: 0)
        output.append("Atlas Lab X НЕ продаёт товары и не использует найденные здесь покупки для локальной учебной подписки.")
        lines = output
    }
}
