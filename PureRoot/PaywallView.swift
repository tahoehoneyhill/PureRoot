//
//  PaywallView.swift
//  PureRoot
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptions

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                features
                purchasePanel
                if let error = subscriptions.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                legalFooter
            }
            .padding(.vertical, 24)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
            Text("PureRoot")
                .font(.largeTitle.bold())
            Text("Know what's in your food. Find clean sources near you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var features: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "magnifyingglass.circle.fill",
                       title: "Ingredient Scanner",
                       detail: "AI breakdown of every additive, preservative, and chemical.")
            FeatureRow(icon: "location.circle.fill",
                       title: "Local Food Finder",
                       detail: "Farmers markets, butchers, food hubs, and CSAs by zip code.")
            FeatureRow(icon: "shippingbox.fill",
                       title: "Nationwide Organic Shippers",
                       detail: "Vetted companies that deliver clean food anywhere in the US.")
            FeatureRow(icon: "leaf.circle.fill",
                       title: "Direct Farm Connections",
                       detail: "Connect small farms with communities across the country.")
        }
        .padding(.horizontal)
    }

    private var purchasePanel: some View {
        VStack(spacing: 12) {
            Text(headlineText)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Cancel anytime in Settings.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                Task { await subscriptions.purchase() }
            } label: {
                Group {
                    if subscriptions.purchaseInFlight {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Start 7-Day Free Trial")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(subscriptions.purchaseInFlight || subscriptions.yearlyProduct == nil)

            Button("Restore Purchases") {
                Task { await subscriptions.restorePurchases() }
            }
            .font(.footnote)

            #if DEBUG
            Button("Skip (dev only)") {
                subscriptions.devBypass()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
            #endif
        }
        .padding(.horizontal)
    }

    private var legalFooter: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Link("Privacy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
            }
            .font(.caption)

            Text("Payment is charged to your Apple ID at the end of the free trial. The subscription auto-renews yearly unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var headlineText: String {
        let price = subscriptions.yearlyProduct?.displayPrice ?? "$4.99"
        return "7 days free, then \(price) per year"
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).fontWeight(.semibold)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PaywallView()
        .environment(SubscriptionManager())
}
