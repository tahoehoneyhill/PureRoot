//
//  Farm.swift
//  PureRoot
//

import Foundation
import SwiftUI

struct Farm: Identifiable {
    let id: String
    let name: String
    let state: String
    let distance: String
    let products: [String]
    let certifications: [String]
    let rating: Double
    let reviews: Int
    let emoji: String
    let description: String
}

enum FarmData {
    static let featured: [Farm] = [
        Farm(id: "blueridge", name: "Blue Ridge Heritage Farm", state: "VA", distance: "—",
             products: ["Vegetables", "Eggs", "Herbs"],
             certifications: ["Organic", "Non-GMO"],
             rating: 4.9, reviews: 142, emoji: "🌿",
             description: "Family-owned since 1987. Heirloom vegetables, pasture-raised eggs, no synthetic inputs ever."),
        Farm(id: "sundown", name: "Sundown Valley Ranch", state: "CA", distance: "—",
             products: ["Beef", "Pork", "Lamb"],
             certifications: ["Grass-Fed", "Humane Certified"],
             rating: 4.8, reviews: 98, emoji: "🐄",
             description: "100% grass-fed, pasture-raised meats. Animals never receive antibiotics or growth hormones."),
        Farm(id: "morningdew", name: "Morning Dew Organics", state: "OR", distance: "—",
             products: ["Fruits", "Berries", "Jams"],
             certifications: ["USDA Organic", "Biodynamic"],
             rating: 5.0, reviews: 211, emoji: "🍓",
             description: "Certified biodynamic since 2003. Seasonal fruits and small-batch preserves without refined sugar."),
        Farm(id: "clearwater", name: "Clearwater Dairy Co.", state: "VT", distance: "—",
             products: ["Milk", "Cheese", "Butter"],
             certifications: ["Organic", "A2 Milk"],
             rating: 4.7, reviews: 87, emoji: "🧀",
             description: "A2 protein dairy from grass-fed Jersey cows. No rBGH, no antibiotics. Low-temp pasteurized."),
        Farm(id: "prairie", name: "Prairie Wind Grains", state: "KS", distance: "—",
             products: ["Wheat", "Corn", "Oats"],
             certifications: ["Non-GMO", "Regenerative"],
             rating: 4.6, reviews: 63, emoji: "🌾",
             description: "Ancient grain varieties grown with regenerative practices. Stone-milled on site."),
        Farm(id: "goldenhive", name: "Golden Hive Apiary", state: "TX", distance: "—",
             products: ["Raw Honey", "Beeswax", "Pollen"],
             certifications: ["Raw", "Wildflower"],
             rating: 4.9, reviews: 174, emoji: "🍯",
             description: "Migratory-free hives managed with no chemicals. Unfiltered, unpasteurized raw honey."),
        Farm(id: "sunflower", name: "Sunflower Hills Farm", state: "PA", distance: "—",
             products: ["Heirloom Vegetables", "Microgreens", "Herbs"],
             certifications: ["Certified Naturally Grown"],
             rating: 4.8, reviews: 91, emoji: "🌻",
             description: "Three-generation family farm growing 60+ heirloom varieties using no-till regenerative methods."),
        Farm(id: "cascade", name: "Cascade Mountain Poultry", state: "WA", distance: "—",
             products: ["Pasture Chicken", "Eggs", "Turkey"],
             certifications: ["Pasture-Raised", "Soy-Free"],
             rating: 4.7, reviews: 108, emoji: "🐔",
             description: "Mobile coop pasture system. Birds rotated daily on fresh grass with non-GMO, soy-free feed."),
    ]
}

struct LocalFarm: Codable, Identifiable {
    var id: String { name + (address ?? "") }
    let name: String
    let address: String?
    let distance: String?
    let products: [String]?
    let certifications: [String]?
    let description: String?
    let website: String?
    let phone: String?
    let ships_nationwide: Bool?
    let csa_available: Bool?
    let u_pick: Bool?
}

private struct FarmSearchResponse: Codable {
    let results: [LocalFarm]
}

@MainActor
@Observable
final class FarmSearch {
    var zipCode: String = ""
    var radius: Int = 25
    var results: [LocalFarm] = []
    var isLoading = false
    var errorMessage: String?
    var hasSearched = false

    func search() async {
        guard zipCode.count == 5, zipCode.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Enter a valid 5-digit US zip code."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let system = """
        You help people find local small farms selling clean food. Use web search to verify real farms that are currently operating. \
        Return ONLY a JSON object — no preamble, no markdown fences, no commentary.
        """

        let prompt = """
        Find small farms (vegetable farms, dairy farms, ranches, orchards, apiaries, poultry farms, CSAs) within \(radius) miles of US zip code \(zipCode). Prioritize farms that sell directly to consumers, offer CSAs, or have farm stands.

        Return ONLY valid JSON in this exact shape (no extra fields, no text before or after):
        {
          "results": [
            {
              "name": "string",
              "address": "string or null",
              "distance": "string like '8 mi' or null",
              "products": ["string"] or null,
              "certifications": ["string"] or null,
              "description": "short string or null",
              "website": "https://... or null",
              "phone": "string or null",
              "ships_nationwide": true | false,
              "csa_available": true | false,
              "u_pick": true | false
            }
          ]
        }

        Aim for 6–12 high-quality results. Only include real farms you can verify with web search.
        """

        do {
            let model = loadPreferredModel() ?? .sonnet
            let raw = try await AnthropicClient.send(
                system: system,
                prompt: prompt,
                model: model,
                useWebSearch: true,
                maxTokens: 4096
            )
            guard let jsonText = AnthropicClient.extractJSON(from: raw),
                  let data = jsonText.data(using: .utf8) else {
                errorMessage = "Couldn't read response. Try a different zip or a larger radius."
                hasSearched = true
                return
            }
            let decoded = try JSONDecoder().decode(FarmSearchResponse.self, from: data)
            results = decoded.results
            hasSearched = true
            if results.isEmpty {
                errorMessage = "No farms found near that zip. Try a larger radius."
            }
        } catch {
            errorMessage = error.localizedDescription
            hasSearched = true
        }
    }

    private func loadPreferredModel() -> AnthropicModel? {
        guard let raw = UserDefaults.standard.string(forKey: "pureroot.anthropic.model") else { return nil }
        return AnthropicModel(rawValue: raw)
    }
}

struct FarmDirectoryView: View {
    @State private var search = FarmSearch()
    @State private var expandedID: String?
    @State private var expandedFeaturedID: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    searchBar
                    if let error = search.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if search.hasSearched && !search.results.isEmpty {
                        sectionHeader("Farms near \(search.zipCode)")
                        ForEach(search.results) { farm in
                            localFarmCard(farm)
                        }
                    }

                    if !search.hasSearched || search.results.isEmpty {
                        sectionHeader("Featured farms across the US")
                        ForEach(FarmData.featured) { farm in
                            featuredFarmCard(farm)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Farms")
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green)
            Text("Find small farms near you — or browse standouts from across the country.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var searchBar: some View {
        VStack(spacing: 10) {
            HStack {
                TextField("Zip code", text: $search.zipCode)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    .padding(10)
                    .background(Color.prInputField)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: 140)

                Picker("Radius", selection: $search.radius) {
                    Text("10 mi").tag(10)
                    Text("25 mi").tag(25)
                    Text("50 mi").tag(50)
                    Text("100 mi").tag(100)
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 8)
                .background(Color.prInputField)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Button {
                Task { await search.search() }
            } label: {
                HStack {
                    if search.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "magnifyingglass")
                        Text("Find farms near me").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(search.isLoading || search.zipCode.isEmpty)
        }
        .padding(.horizontal)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func localFarmCard(_ farm: LocalFarm) -> some View {
        let isExpanded = expandedID == farm.id
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedID = isExpanded ? nil : farm.id
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.green)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(farm.name).font(.headline).foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            if let d = farm.distance {
                                Text(d).font(.caption2).foregroundStyle(.secondary)
                            }
                            if farm.csa_available == true {
                                tagPill("CSA", color: .green)
                            }
                            if farm.u_pick == true {
                                tagPill("U-Pick", color: .orange)
                            }
                            if farm.ships_nationwide == true {
                                tagPill("Ships", color: .blue)
                            }
                        }
                        if let desc = farm.description, !isExpanded {
                            Text(desc).font(.footnote).foregroundStyle(.secondary).lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if let desc = farm.description { Text(desc).font(.footnote) }
                    if let addr = farm.address { detailLine("Address", addr) }
                    if let products = farm.products, !products.isEmpty {
                        FlexibleChipLayout(values: products)
                    }
                    if let certs = farm.certifications, !certs.isEmpty {
                        FlexibleChipLayout(values: certs)
                    }
                    actionButtons(farm)
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

    private func featuredFarmCard(_ farm: Farm) -> some View {
        let isExpanded = expandedFeaturedID == farm.id
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedFeaturedID = isExpanded ? nil : farm.id
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Text(farm.emoji).font(.system(size: 36))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(farm.name).font(.headline).foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            tagPill(farm.state, color: .green)
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                                Text(String(format: "%.1f", farm.rating))
                                    .font(.caption.weight(.semibold))
                                Text("(\(farm.reviews))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if !isExpanded {
                            Text(farm.description)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(farm.description).font(.footnote)
                    FlexibleChipLayout(values: farm.products)
                    FlexibleChipLayout(values: farm.certifications)
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

    private func tagPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func detailLine(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value).font(.footnote)
        }
    }

    private func actionButtons(_ farm: LocalFarm) -> some View {
        HStack(spacing: 8) {
            if let addr = farm.address,
               let url = URL(string: "https://maps.apple.com/?q=\(addr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                Link(destination: url) { actionLabel("Directions", icon: "map.fill") }
            }
            if let web = farm.website, let url = URL(string: web) {
                Link(destination: url) { actionLabel("Website", icon: "globe") }
            }
            if let phone = farm.phone, let url = URL(string: "tel:\(phone.filter { $0.isNumber })") {
                Link(destination: url) { actionLabel("Call", icon: "phone.fill") }
            }
        }
    }

    private func actionLabel(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption)
            Text(text).font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(Color.green.opacity(0.15))
        .foregroundStyle(.green)
        .clipShape(Capsule())
    }
}
