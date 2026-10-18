import Foundation
import StoreKit

// A real StoreKit 2 inspection path. No paid product is configured for this lab bundle ID,
// so this normally finds no products/transactions. It never initiates a purchase.
enum StoreKitInspector {
    static func diagnostic() async -> String {
        do {
            let products = try await Product.products(for: ["com.reverselab.atlastraining.pro.monthly"])
            var verified = 0
            for await item in Transaction.currentEntitlements {
                if case .verified(_) = item { verified += 1 }
            }
            return "StoreKit 2: продуктов \(products.count), подтверждённых прав \(verified). Учебная лицензия с ними не связана."
        } catch {
            return "StoreKit 2: \(error.localizedDescription). Учебная локальная лицензия работает отдельно."
        }
    }
}
