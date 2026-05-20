//
//  SubscriptionManager.swift
//  PureRoot
//

import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class SubscriptionManager {
    static let yearlyProductID = "com.purerootfood.yearly"

    private(set) var yearlyProduct: Product?
    private(set) var isSubscribed = false
    private(set) var isLoadingProducts = false
    private(set) var purchaseInFlight = false
    private(set) var lastError: String?

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await refreshSubscriptionStatus()
        }
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let products = try await Product.products(for: [Self.yearlyProductID])
            yearlyProduct = products.first
        } catch {
            lastError = "Could not load subscription: \(error.localizedDescription)"
        }
    }

    func purchase() async {
        guard let product = yearlyProduct else {
            lastError = "Subscription not available right now."
            return
        }
        purchaseInFlight = true
        defer { purchaseInFlight = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshSubscriptionStatus()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshSubscriptionStatus()
        } catch {
            lastError = "Restore failed: \(error.localizedDescription)"
        }
    }

    #if DEBUG
    func devBypass() {
        isSubscribed = true
    }
    #endif

    func refreshSubscriptionStatus() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.productID == Self.yearlyProductID,
                  transaction.revocationDate == nil else { continue }
            if let expiration = transaction.expirationDate, expiration < Date() { continue }
            active = true
        }
        isSubscribed = active
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshSubscriptionStatus()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }
}
