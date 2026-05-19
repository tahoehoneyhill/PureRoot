//
//  LocalFoodFinderView.swift
//  PureRoot
//

import SwiftUI

enum LocalPlaceCategory: String, Codable, CaseIterable, Identifiable {
    case farmersMarket = "farmers_market"
    case foodHub = "food_hub"
    case butcher = "butcher"
    case farmCSA = "farm_csa"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .farmersMarket: return "Farmers Markets"
        case .foodHub: return "Food Hubs"
        case .butcher: return "Butchers"
        case .farmCSA: return "Farms & CSAs"
        }
    }

    var icon: String {
        switch self {
        case .farmersMarket: return "basket.fill"
        case .foodHub: return "building.2.fill"
        case .butcher: return "fork.knife"
        case .farmCSA: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .farmersMarket: return .orange
        case .foodHub: return .purple
        case .butcher: return .red
        case .farmCSA: return .green
        }
    }
}

struct LocalPlace: Codable, Identifiable {
    var id: String { name + (address ?? "") }
    let name: String
    let category: LocalPlaceCategory
    let address: String?
    let distance: String?
    let hours: String?
    let description: String?
    let products: [String]?
    let website: String?
    let phone: String?
    let ships_nationwide: Bool?
    let seasonal: Bool?
}

private struct LocalSearchResponse: Codable {
    let results: [LocalPlace]
}

@MainActor
@Observable
final class LocalFoodSearch {
    var zipCode: String = ""
    var radius: Int = 25
    var results: [LocalPlace] = []
    var selectedCategoryFilter: LocalPlaceCategory? = nil
    var isLoading = false
    var errorMessage: String?

    func search() async {
        guard zipCode.count == 5, zipCode.allSatisfy({ $0.isNumber }) else {
            errorMessage = "Enter a valid 5-digit US zip code."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let system = """
        You help people find clean local food sources. Use web search to find real, currently operating places. \
        Return ONLY a JSON object — no preamble, no markdown fences, no commentary.
        """

        let prompt = """
        Find currently operating farmers markets, food hubs, butchers selling clean meat, and small farms or CSAs within \(radius) miles of US zip code \(zipCode).

        Return ONLY valid JSON in this exact shape (no extra fields, no text before or after):
        {
          "results": [
            {
              "name": "string",
              "category": "farmers_market" | "food_hub" | "butcher" | "farm_csa",
              "address": "string or null",
              "distance": "string like '8 mi' or null",
              "hours": "string or null",
              "description": "short string or null",
              "products": ["string"] or null,
              "website": "https://... or null",
              "phone": "string or null",
              "ships_nationwide": true | false,
              "seasonal": true | false
            }
          ]
        }

        Aim for 6–12 high-quality results. Only include real places you can verify with web search.
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
                return
            }
            let decoded = try JSONDecoder().decode(LocalSearchResponse.self, from: data)
            results = decoded.results
            if results.isEmpty {
                errorMessage = "No local sources found. Try a larger radius or check the Ships Nationwide tab."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadPreferredModel() -> AnthropicModel? {
        guard let raw = UserDefaults.standard.string(forKey: "pureroot.anthropic.model") else { return nil }
        return AnthropicModel(rawValue: raw)
    }

    func countsByCategory() -> [LocalPlaceCategory: Int] {
        Dictionary(grouping: results, by: { $0.category }).mapValues { $0.count }
    }

    var filteredResults: [LocalPlace] {
        guard let cat = selectedCategoryFilter else { return results }
        return results.filter { $0.category == cat }
    }
}

struct LocalFoodFinderView: View {
    @State private var search = LocalFoodSearch()
    @State private var expandedID: String?

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
                    if !search.results.isEmpty {
                        categoryTiles
                        ForEach(search.filteredResults) { place in
                            placeCard(place)
                        }
                    } else if !search.isLoading {
                        emptyState
                    }
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
            Text("Farmers markets, food hubs, butchers, and CSAs near you.")
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
                    Text("5 mi").tag(5)
                    Text("10 mi").tag(10)
                    Text("25 mi").tag(25)
                    Text("50 mi").tag(50)
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
                        Text("Search").fontWeight(.semibold)
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

    private var categoryTiles: some View {
        let counts = search.countsByCategory()
        return HStack(spacing: 8) {
            ForEach(LocalPlaceCategory.allCases) { cat in
                Button {
                    if search.selectedCategoryFilter == cat {
                        search.selectedCategoryFilter = nil
                    } else {
                        search.selectedCategoryFilter = cat
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: cat.icon).foregroundStyle(cat.color)
                        Text("\(counts[cat] ?? 0)").font(.headline)
                        Text(cat.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(search.selectedCategoryFilter == cat ? cat.color.opacity(0.18) : Color.prInputField)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private func placeCard(_ place: LocalPlace) -> some View {
        let isExpanded = expandedID == place.id
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedID = isExpanded ? nil : place.id
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: place.category.icon)
                        .foregroundStyle(place.category.color)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name).font(.headline).foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            Text(place.category.label.dropLast().description)
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(place.category.color.opacity(0.15))
                                .foregroundStyle(place.category.color)
                                .clipShape(Capsule())
                            if let d = place.distance {
                                Text(d).font(.caption2).foregroundStyle(.secondary)
                            }
                            if place.ships_nationwide == true {
                                Text("Ships nationwide")
                                    .font(.caption2)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                            if place.seasonal == true {
                                Text("Seasonal")
                                    .font(.caption2)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundStyle(.orange)
                                    .clipShape(Capsule())
                            }
                        }
                        if let desc = place.description, !isExpanded {
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
                    if let desc = place.description { Text(desc).font(.footnote) }
                    if let addr = place.address { detailLine("Address", addr) }
                    if let hours = place.hours { detailLine("Hours", hours) }
                    if let products = place.products, !products.isEmpty {
                        FlexibleChipLayout(values: products)
                    }
                    actionButtons(place)
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

    private func detailLine(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value).font(.footnote)
        }
    }

    private func actionButtons(_ place: LocalPlace) -> some View {
        HStack(spacing: 8) {
            if let addr = place.address,
               let url = URL(string: "https://maps.apple.com/?q=\(addr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                Link(destination: url) { actionLabel("Directions", icon: "map.fill") }
            }
            if let web = place.website, let url = URL(string: web) {
                Link(destination: url) { actionLabel("Website", icon: "globe") }
            }
            if let phone = place.phone, let url = URL(string: "tel:\(phone.filter { $0.isNumber })") {
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

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Enter a zip code to get started.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Requires an Anthropic API key in Settings.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 32)
    }
}
