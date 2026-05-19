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
    let products: [String]
    let certifications: [String]
    let rating: Double
    let reviews: Int
    let emoji: String
    let description: String
}

enum FarmData {
    static let featured: [Farm] = [
        Farm(id: "blueridge", name: "Blue Ridge Heritage Farm", state: "VA",
             products: ["Vegetables", "Eggs", "Herbs"],
             certifications: ["Organic", "Non-GMO"],
             rating: 4.9, reviews: 142, emoji: "🌿",
             description: "Family-owned since 1987. Heirloom vegetables, pasture-raised eggs, no synthetic inputs ever."),
        Farm(id: "sundown", name: "Sundown Valley Ranch", state: "CA",
             products: ["Beef", "Pork", "Lamb"],
             certifications: ["Grass-Fed", "Humane Certified"],
             rating: 4.8, reviews: 98, emoji: "🐄",
             description: "100% grass-fed, pasture-raised meats. Animals never receive antibiotics or growth hormones."),
        Farm(id: "morningdew", name: "Morning Dew Organics", state: "OR",
             products: ["Fruits", "Berries", "Jams"],
             certifications: ["USDA Organic", "Biodynamic"],
             rating: 5.0, reviews: 211, emoji: "🍓",
             description: "Certified biodynamic since 2003. Seasonal fruits and small-batch preserves without refined sugar."),
        Farm(id: "clearwater", name: "Clearwater Dairy Co.", state: "VT",
             products: ["Milk", "Cheese", "Butter"],
             certifications: ["Organic", "A2 Milk"],
             rating: 4.7, reviews: 87, emoji: "🧀",
             description: "A2 protein dairy from grass-fed Jersey cows. No rBGH, no antibiotics. Low-temp pasteurized."),
        Farm(id: "prairie", name: "Prairie Wind Grains", state: "KS",
             products: ["Wheat", "Corn", "Oats"],
             certifications: ["Non-GMO", "Regenerative"],
             rating: 4.6, reviews: 63, emoji: "🌾",
             description: "Ancient grain varieties grown with regenerative practices. Stone-milled on site."),
        Farm(id: "goldenhive", name: "Golden Hive Apiary", state: "TX",
             products: ["Raw Honey", "Beeswax", "Pollen"],
             certifications: ["Raw", "Wildflower"],
             rating: 4.9, reviews: 174, emoji: "🍯",
             description: "Migratory-free hives managed with no chemicals. Unfiltered, unpasteurized raw honey."),
        Farm(id: "sunflower", name: "Sunflower Hills Farm", state: "PA",
             products: ["Heirloom Vegetables", "Microgreens", "Herbs"],
             certifications: ["Certified Naturally Grown"],
             rating: 4.8, reviews: 91, emoji: "🌻",
             description: "Three-generation family farm growing 60+ heirloom varieties using no-till regenerative methods."),
        Farm(id: "cascade", name: "Cascade Mountain Poultry", state: "WA",
             products: ["Pasture Chicken", "Eggs", "Turkey"],
             certifications: ["Pasture-Raised", "Soy-Free"],
             rating: 4.7, reviews: 108, emoji: "🐔",
             description: "Mobile coop pasture system. Birds rotated daily on fresh grass with non-GMO, soy-free feed."),
    ]

    static let allStates: [String] = ["All"] + Array(Set(featured.map { $0.state })).sorted()
}

struct FarmDirectoryView: View {
    @State private var selectedState: String = "All"
    @State private var expandedID: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    header
                    stateFilter
                    ForEach(filtered) { farm in
                        farmCard(farm)
                    }
                    findMoreCard
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
            Text("Featured small farms across the US.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var stateFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FarmData.allStates, id: \.self) { state in
                    Button {
                        selectedState = state
                    } label: {
                        Text(state)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedState == state ? Color.green : Color.prInputField)
                            .foregroundStyle(selectedState == state ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private var filtered: [Farm] {
        FarmData.featured.filter { selectedState == "All" || $0.state == selectedState }
    }

    private func farmCard(_ farm: Farm) -> some View {
        let isExpanded = expandedID == farm.id
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedID = isExpanded ? nil : farm.id
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Text(farm.emoji).font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(farm.name).font(.headline).foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            Text(farm.state)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
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
                VStack(alignment: .leading, spacing: 10) {
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

    private var findMoreCard: some View {
        Link(destination: URL(string: "https://www.localharvest.org/")!) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Find more local farms").font(.headline).foregroundStyle(.white)
                    Text("Search 40,000+ US farms by zip on LocalHarvest")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding()
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
