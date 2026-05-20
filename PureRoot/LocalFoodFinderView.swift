//
//  LocalFoodFinderView.swift
//  PureRoot
//

import SwiftUI

struct LocalDirectoryEntry: Identifiable {
    let id: String
    let name: String
    let tagline: String
    let description: String
    let url: String
    let category: String
    let icon: String
}

enum LocalDirectoryData {
    static let entries: [LocalDirectoryEntry] = [
        LocalDirectoryEntry(id: "localharvest", name: "LocalHarvest",
                            tagline: "Largest US directory of small farms and CSAs",
                            description: "Search by zip code for organic farms, farmers markets, and CSA subscriptions across the entire US. Over 40,000 listings.",
                            url: "https://www.localharvest.org/", category: "Farms & CSAs", icon: "leaf.fill"),
        LocalDirectoryEntry(id: "usdamarkets", name: "USDA Farmers Market Directory",
                            tagline: "Official government directory of US farmers markets",
                            description: "Federal database of every registered farmers market in the country. Updated regularly by the USDA.",
                            url: "https://www.usdalocalfoodportal.com/", category: "Farmers Markets", icon: "basket.fill"),
        LocalDirectoryEntry(id: "eatwild", name: "Eat Wild",
                            tagline: "Grass-fed pasture-based meat directory",
                            description: "The original directory of family farms selling grass-fed beef, pastured pork, free-range poultry, and raw dairy. Browse by state.",
                            url: "https://www.eatwild.com/", category: "Grass-Fed Meat", icon: "fork.knife"),
        LocalDirectoryEntry(id: "realmilk", name: "Real Milk Finder",
                            tagline: "Raw dairy sources near you",
                            description: "Maintained by the Weston A. Price Foundation. Find legal raw milk, cheese, and dairy in your state along with state legal status.",
                            url: "https://www.realmilk.com/real-milk-finder/", category: "Raw Dairy", icon: "drop.fill"),
        LocalDirectoryEntry(id: "pickyourown", name: "Pick Your Own",
                            tagline: "U-pick farms and orchards by state",
                            description: "Find pick-your-own farms for fruit, vegetables, pumpkins, Christmas trees, and more. Includes seasonal calendars by state.",
                            url: "https://www.pickyourown.org/", category: "U-Pick Farms", icon: "hand.raised.fill"),
        LocalDirectoryEntry(id: "cornucopia", name: "Cornucopia Institute",
                            tagline: "Organic brand scorecards",
                            description: "Independently rates organic brands across dairy, eggs, soy, cereals, and produce. Find out which 'organic' brands are actually clean.",
                            url: "https://www.cornucopia.org/scorecards/", category: "Brand Ratings", icon: "checkmark.seal.fill"),
        LocalDirectoryEntry(id: "slowfood", name: "Slow Food USA",
                            tagline: "Network of local food chapters",
                            description: "Find your local Slow Food chapter for community events, farm tours, ark-of-taste heritage foods, and direct producer connections.",
                            url: "https://slowfoodusa.org/", category: "Community", icon: "person.3.fill"),
        LocalDirectoryEntry(id: "openfoodfacts", name: "Open Food Facts",
                            tagline: "Free product ingredient database",
                            description: "The barcode database powering PureRootFood's scanner. Look up any product to see ingredients, additives, and NOVA processing scores.",
                            url: "https://world.openfoodfacts.org/", category: "Product Lookup", icon: "barcode.viewfinder"),
    ]
}

struct LocalFoodFinderView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    ForEach(LocalDirectoryData.entries) { entry in
                        entryCard(entry)
                    }
                    footer
                }
                .padding(.vertical)
            }
            .navigationTitle("Find Local Food")
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green)
            Text("Trusted directories for clean food near you.")
                .font(.headline)
            Text("Each link opens an external US directory. Search by zip code on each site to find local farms, markets, raw dairy, and pasture-raised meat.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private func entryCard(_ entry: LocalDirectoryEntry) -> some View {
        Link(destination: URL(string: entry.url)!) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: entry.icon)
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(entry.tagline)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                    Text(entry.description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    Text(entry.category)
                        .font(.caption2)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.green.opacity(0.12))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color.prCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Color.prDivider, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    private var footer: some View {
        Text("PureRootFood doesn't operate these directories — they're independent, well-established US resources we trust. Coming soon: built-in zip-code search.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}
