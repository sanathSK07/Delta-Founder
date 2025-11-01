//
//  SubscriptionManager.swift
//  HealthTrackAI
//
//  StoreKit 2 subscription management
//

import Foundation
import StoreKit

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isSubscribed = false
    @Published var currentSubscription: Product?

    private let productIds = [
        "com.healthtrackai.premium.monthly",
        "com.healthtrackai.premium.annual"
    ]

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Fetch Products

    func fetchProducts() async -> [Product] {
        do {
            let products = try await Product.products(for: productIds)
            return products.sorted { $0.price < $1.price }
        } catch {
            print("Failed to fetch products: \(error)")
            return []
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updateSubscriptionStatus()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    // MARK: - Check Subscription Status

    func updateSubscriptionStatus() async {
        var isActive = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if subscription is active
                if productIds.contains(transaction.productID) {
                    isActive = true
                    break
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }

        await MainActor.run {
            self.isSubscribed = isActive
        }
    }

    // MARK: - Listen for Transactions

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helpers

    func formattedPrice(for product: Product) -> String {
        return product.displayPrice
    }

    func subscriptionPeriod(for product: Product) -> String {
        guard let subscription = product.subscription else {
            return ""
        }

        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value

        switch unit {
        case .day:
            return value == 1 ? "day" : "\(value) days"
        case .week:
            return value == 1 ? "week" : "\(value) weeks"
        case .month:
            return value == 1 ? "month" : "\(value) months"
        case .year:
            return value == 1 ? "year" : "\(value) years"
        @unknown default:
            return ""
        }
    }
}

enum SubscriptionError: Error {
    case verificationFailed
    case purchaseFailed
}
