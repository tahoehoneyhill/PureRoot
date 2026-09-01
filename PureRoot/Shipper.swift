//
//  Shipper.swift
//  PureRoot
//

import Foundation
import Observation
import SwiftUI

enum ShipperCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case grocery = "Grocery & Pantry"
    case meatSeafood = "Meat & Seafood"
    case produce = "Produce"
    case mealKits = "Meal Kits"
    case bulk = "Bulk Organic"
    case traditional = "Traditional Foods"
    case snacks = "Snacks & Supplements"

    var id: String { rawValue }
}

struct Shipper: Identifiable {
    let id: String
    let name: String
    let category: ShipperCategory
    let highlight: String
    let why: String
    let howItWorks: String
    let products: [String]
    let certifications: [String]
    let tags: [String]
    let url: String
}

enum ShipperData {
    static let all: [Shipper] = [
        Shipper(id: "thrive", name: "Thrive Market", category: .grocery,
                highlight: "Largest vetted organic online store, no artificial anything",
                why: "Every product is screened against a long banned-ingredients list. Membership model means lower prices on the same clean brands you'd buy retail.",
                howItWorks: "Annual membership unlocks 30–40% savings on thousands of organic and non-GMO grocery items. Ships nationwide in 2–5 days.",
                products: ["Pantry staples", "Snacks", "Supplements", "Clean beauty", "Wine"],
                certifications: ["Non-GMO", "Organic", "Banned-list screened"],
                tags: ["membership", "no artificial"],
                url: "https://thrivemarket.com"),
        Shipper(id: "butcherbox", name: "ButcherBox", category: .meatSeafood,
                highlight: "100% grass-fed, humanely raised, no factory farms",
                why: "All beef is grass-fed and grass-finished, pork is heritage-breed, chicken is organic and free-range. No antibiotics or added hormones, ever.",
                howItWorks: "Monthly curated or custom box of meat and seafood, frozen and shipped nationwide. Skip or cancel anytime.",
                products: ["Beef", "Chicken", "Pork", "Wild seafood"],
                certifications: ["Grass-fed", "Humane Certified", "No antibiotics"],
                tags: ["grass-fed", "no antibiotics"],
                url: "https://butcherbox.com"),
        Shipper(id: "misfits", name: "Misfits Market", category: .produce,
                highlight: "Organic produce boxes, 40% below grocery prices",
                why: "Rescues cosmetically imperfect organic produce that would otherwise be wasted. Same nutrition, lower price.",
                howItWorks: "Customize a weekly box of organic produce and grocery. Skip any week. Ships to most of the US.",
                products: ["Organic produce", "Grocery", "Meat", "Dairy"],
                certifications: ["USDA Organic", "Non-GMO"],
                tags: ["organic", "produce box"],
                url: "https://misfitsmarket.com"),
        Shipper(id: "farmbox", name: "FarmBox Direct", category: .produce,
                highlight: "Partners with actual small farms, includes farm notes",
                why: "Sources from real small and mid-size organic farms across the US. Each box includes a note about which farms grew what.",
                howItWorks: "Weekly or bi-weekly box, choose all-fruit, all-veggie, or mixed. Sizes for one person up to a family.",
                products: ["Organic fruits", "Organic vegetables"],
                certifications: ["USDA Organic", "Non-GMO"],
                tags: ["small farms", "organic"],
                url: "https://farmboxdirect.com"),
        Shipper(id: "vital", name: "Vital Choice", category: .meatSeafood,
                highlight: "Wild-caught seafood, tested for mercury & contaminants",
                why: "The gold standard for wild Alaskan salmon and seafood. Every batch is third-party tested for purity.",
                howItWorks: "One-time orders or subscriptions. Frozen at peak freshness, shipped overnight.",
                products: ["Wild salmon", "Halibut", "Cod", "Shellfish", "Pasture-raised meat"],
                certifications: ["Wild-caught", "MSC Sustainable", "Third-party tested"],
                tags: ["wild-caught", "mercury-tested"],
                url: "https://vitalchoice.com"),
        Shipper(id: "goodchop", name: "Good Chop", category: .meatSeafood,
                highlight: "100% American sourced, no imports, no factory farms",
                why: "Every cut comes from independent American farmers and ranchers. No imported meat, no factory farms.",
                howItWorks: "Customize a monthly box of meat and seafood. Includes butcher cards from real farms.",
                products: ["Beef", "Pork", "Chicken", "Seafood"],
                certifications: ["American sourced", "No antibiotics"],
                tags: ["American farms", "no factory farms"],
                url: "https://goodchop.com"),
        Shipper(id: "sunbasket", name: "Sun Basket", category: .mealKits,
                highlight: "USDA organic meal kits, zero artificial ingredients",
                why: "Only meal-kit company with consistent USDA Organic certification. Designed by a chef and a nutritionist.",
                howItWorks: "Choose recipes weekly. Pre-portioned organic ingredients shipped chilled, ready to cook in 20–35 minutes.",
                products: ["Meal kits", "Prepared meals", "Breakfast", "Snacks"],
                certifications: ["USDA Organic", "Non-GMO"],
                tags: ["organic", "chef-designed"],
                url: "https://sunbasket.com"),
        Shipper(id: "azure", name: "Azure Standard", category: .bulk,
                highlight: "Best value bulk organic, community drop-point network",
                why: "Family-owned, certified organic since 1971. Massive selection of bulk organic grains, flours, beans, and pantry items at wholesale prices.",
                howItWorks: "Order monthly, pick up at a local Azure drop point or get home delivery in select areas. Save 20–50% buying in bulk.",
                products: ["Bulk grains", "Flours", "Beans", "Oils", "Supplements", "Pantry"],
                certifications: ["USDA Organic", "Non-GMO"],
                tags: ["bulk", "wholesale prices"],
                url: "https://azurestandard.com"),
        Shipper(id: "radiant", name: "Radiant Life", category: .traditional,
                highlight: "Organ meats, raw dairy, ancestral nutrition",
                why: "Sources traditional, nutrient-dense foods that are hard to find anywhere else — pasture-raised organ meats, real fermented foods, raw dairy products.",
                howItWorks: "Order online, shipped frozen or shelf-stable depending on the product.",
                products: ["Organ meats", "Bone broth", "Fermented foods", "Traditional fats"],
                certifications: ["Pasture-raised", "Grass-fed"],
                tags: ["ancestral", "nutrient-dense"],
                url: "https://radiantlifecatalog.com"),
        Shipper(id: "onceagain", name: "Once Again Nut Butter", category: .grocery,
                highlight: "Worker-owned co-op, Regenerative Organic Certified, zero additives",
                why: "Worker-owned cooperative since 1976. Just nuts (and salt if you want it) — no palm oil, no emulsifiers, no sugar.",
                howItWorks: "Order direct or find in stores. Pantry-stable, ships nationwide.",
                products: ["Peanut butter", "Almond butter", "Cashew butter", "Tahini", "Honey"],
                certifications: ["Regenerative Organic Certified", "USDA Organic", "Non-GMO"],
                tags: ["worker-owned", "no additives"],
                url: "https://onceagainnutbutter.com"),
        Shipper(id: "primal", name: "Primal Pastures", category: .meatSeafood,
                highlight: "Only widely available soy-free, corn-free pasture-raised poultry",
                why: "Family farm in California. Chicken raised on pasture without soy or corn feed — extremely rare in commercial poultry.",
                howItWorks: "Order online, frozen, shipped nationwide in insulated boxes.",
                products: ["Pasture-raised chicken", "Turkey", "Beef", "Lamb"],
                certifications: ["Pasture-raised", "Soy-free", "Corn-free"],
                tags: ["soy-free", "pasture-raised"],
                url: "https://primalpastures.com"),
        Shipper(id: "paleovalley", name: "Paleovalley", category: .snacks,
                highlight: "Cleanest meat snacks, naturally fermented, third-party tested",
                why: "100% grass-fed beef sticks naturally fermented (not chemically cured). No sugar, no soy, no junk.",
                howItWorks: "One-time orders or subscribe and save. Shelf-stable, ships nationwide.",
                products: ["Beef sticks", "Pork sticks", "Bone broth protein", "Supplements"],
                certifications: ["Grass-fed", "Naturally fermented", "Third-party tested"],
                tags: ["grass-fed", "no sugar"],
                url: "https://paleovalley.com"),
    ]
}

struct NationwideShippersView: View {
    @Environment(DirectoryStore.self) private var directory
    @State private var selectedCategory: ShipperCategory
    @State private var bookmarks: Set<String> = Self.loadBookmarks()
    @State private var expandedID: String?
    @State private var showBookmarksOnly = false
    private let onDone: (() -> Void)?

    init(initialCategory: ShipperCategory = .all, onDone: (() -> Void)? = nil) {
        _selectedCategory = State(initialValue: initialCategory)
        self.onDone = onDone
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    header
                    categoryPicker
                    Toggle("Show bookmarked only", isOn: $showBookmarksOnly)
                        .font(.footnote)
                        .padding(.horizontal)
                    ForEach(filtered) { shipper in
                        shipperCard(shipper)
                    }
                    if filtered.isEmpty {
                        Text("No shippers match this filter.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Ships Nationwide")
            .toolbar {
                if let onDone {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: onDone)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green)
            Text("Hand-vetted organic companies that deliver clean food anywhere in the US.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ShipperCategory.allCases) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        Text(cat.rawValue)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedCategory == cat ? Color.green : Color.prInputField)
                            .foregroundStyle(selectedCategory == cat ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private var filtered: [Shipper] {
        directory.shippers.filter { s in
            let categoryMatch = selectedCategory == .all || s.category == selectedCategory
            let bookmarkMatch = !showBookmarksOnly || bookmarks.contains(s.id)
            return categoryMatch && bookmarkMatch
        }
    }

    private func shipperCard(_ shipper: Shipper) -> some View {
        let isExpanded = expandedID == shipper.id
        let isBookmarked = bookmarks.contains(shipper.id)

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedID = isExpanded ? nil : shipper.id
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shipper.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(shipper.category.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(shipper.highlight)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        Button {
                            toggleBookmark(shipper.id)
                        } label: {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    detailRow(title: "Why PureRootFood recommends it", body: shipper.why)
                    detailRow(title: "How it works", body: shipper.howItWorks)
                    if !shipper.products.isEmpty {
                        chipRow(title: "Carries", values: shipper.products)
                    }
                    if !shipper.certifications.isEmpty {
                        chipRow(title: "Certifications", values: shipper.certifications)
                    }
                    if let url = URL(string: shipper.url) {
                        Link(destination: url) {
                            HStack {
                                Text("Visit \(shipper.name)")
                                    .font(.footnote.weight(.semibold))
                                Image(systemName: "arrow.up.right.square")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.prDivider, lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    private func detailRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(body)
                .font(.footnote)
        }
    }

    private func chipRow(title: String, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            FlexibleChipLayout(values: values)
        }
    }

    private func toggleBookmark(_ id: String) {
        if bookmarks.contains(id) {
            bookmarks.remove(id)
        } else {
            bookmarks.insert(id)
        }
        Self.saveBookmarks(bookmarks)
    }

    private static let bookmarksKey = "pureroot.shippers.bookmarks"

    private static func loadBookmarks() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: bookmarksKey) ?? [])
    }

    private static func saveBookmarks(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: bookmarksKey)
    }
}

struct FlexibleChipLayout: View {
    let values: [String]

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 80), spacing: 6)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
            ForEach(values, id: \.self) { v in
                Text(v)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.12))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Auto-updating directory

/// Codable mirror of the hosted directory feed. Every field is optional so a
/// partial or evolving feed never fails to decode; missing sections simply fall
/// back to the values already loaded.
private struct DirectoryFeed: Codable {
    let shippers: [ShipperDTO]?
    let farms: [FarmDTO]?
}

private struct ShipperDTO: Codable {
    let id: String
    let name: String
    let category: String
    let highlight: String
    let why: String
    let howItWorks: String
    let products: [String]
    let certifications: [String]
    let tags: [String]
    let url: String

    var model: Shipper {
        Shipper(id: id, name: name,
                category: ShipperCategory(rawValue: category) ?? .grocery,
                highlight: highlight, why: why, howItWorks: howItWorks,
                products: products, certifications: certifications,
                tags: tags, url: url)
    }
}

private struct FarmDTO: Codable {
    let id: String
    let name: String
    let state: String
    let products: [String]
    let certifications: [String]
    let emoji: String
    let description: String

    var model: Farm {
        Farm(id: id, name: name, state: state, products: products,
             certifications: certifications, emoji: emoji, description: description)
    }
}

/// Single source of truth for the farm and shipper directories. Ships with the
/// hand-vetted defaults baked in, loads the last-fetched copy from disk on
/// launch, then refreshes from the hosted feed so listings can be kept current
/// without shipping a new app build. If the network or feed is unavailable, the
/// most recent good data (cache, then bundled defaults) is used.
@Observable
final class DirectoryStore {
    private(set) var shippers: [Shipper]
    private(set) var farms: [Farm]
    private(set) var lastUpdated: Date?

    /// Hosted on the app's existing GitHub Pages site. Edit this JSON file to
    /// update what every user sees — no App Store release required.
    static let feedURL = URL(string: "https://tahoehoneyhill.github.io/purerootfood/directory.json")!

    init() {
        let cached = Self.loadCache()
        shippers = cached?.shippers?.map(\.model) ?? ShipperData.all
        farms = cached?.farms?.map(\.model) ?? FarmData.featured
    }

    /// Fetches the latest directory. Safe to call on every launch; failures are
    /// silent and leave the existing listings untouched.
    @MainActor
    func refresh() async {
        do {
            var request = URLRequest(url: Self.feedURL)
            request.setValue("PureRootFood/1.0 (iOS app)", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 20
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else { return }

            let feed = try JSONDecoder().decode(DirectoryFeed.self, from: data)
            if let s = feed.shippers, !s.isEmpty { shippers = s.map(\.model) }
            if let f = feed.farms, !f.isEmpty { farms = f.map(\.model) }
            lastUpdated = Date()
            Self.saveCache(data)
        } catch {
            // Keep whatever we already have (cache or bundled defaults).
        }
    }

    // MARK: Disk cache

    private static var cacheURL: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("pureroot-directory.json")
    }

    private static func loadCache() -> DirectoryFeed? {
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        return try? JSONDecoder().decode(DirectoryFeed.self, from: data)
    }

    private static func saveCache(_ data: Data) {
        try? data.write(to: cacheURL, options: .atomic)
    }
}
