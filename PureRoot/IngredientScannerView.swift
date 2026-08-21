//
//  IngredientScannerView.swift
//  PureRoot
//

import SwiftUI

struct IngredientScannerView: View {
    @State private var inputText: String = ""
    @State private var analysis: IngredientAnalysis?
    @State private var expandedID: AnalyzedIngredient.ID?

    @State private var showScanner = false
    @State private var showSources = false
    @State private var alternativesCategory: ShipperCategory?
    @State private var scannedProduct: OpenFoodFactsProduct?
    @State private var productLookupInFlight = false
    @State private var productLookupError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    intro
                    scanCard
                    if let scannedProduct {
                        productCard(scannedProduct)
                    }
                    inputCard
                    if productLookupInFlight {
                        ProgressView("Looking up product…")
                            .padding()
                    }
                    if let productLookupError {
                        Text(productLookupError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    if let analysis {
                        verdictBadge(analysis)
                        if analysis.hasCarcinogens {
                            carcinogenBanner(analysis)
                        }
                        if analysis.hasContaminantExposures {
                            contaminantExposureCard(analysis)
                        }
                        scoreCard(analysis)
                        summaryStrip(analysis)
                        if SaferAlternatives.shouldSuggest(for: analysis) {
                            saferAlternativesCard
                        }
                        ingredientsList(analysis)
                        sourcesCard
                    }
                }
                .padding()
            }
            .navigationTitle("Ingredient Scanner")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSources = true
                    } label: {
                        Label("Sources", systemImage: "books.vertical")
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                BarcodeScannerSheet { code in
                    Task { await lookupBarcode(code) }
                }
            }
            .sheet(isPresented: $showSources) {
                sourcesSheet
            }
            .sheet(item: $alternativesCategory) { category in
                NationwideShippersView(initialCategory: category) {
                    alternativesCategory = nil
                }
            }
        }
    }

    private var intro: some View {
        VStack(spacing: 6) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            Text("Scan a barcode or paste an ingredient list to see what's really in it.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var scanCard: some View {
        Button {
            scannedProduct = nil
            productLookupError = nil
            showScanner = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "barcode.viewfinder")
                    .font(.title2)
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scan barcode").font(.headline).foregroundStyle(.white)
                    Text("Camera-scan any product")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func productCard(_ product: OpenFoodFactsProduct) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = product.imageURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "shippingbox.fill")
                        .foregroundStyle(.secondary)
                }
                .frame(width: 72, height: 72)
                .background(Color.prInputField)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(product.displayName).font(.headline)
                if let brand = product.brandName {
                    Text(brand).font(.caption).foregroundStyle(.secondary)
                }
                if let nova = product.nova_group, let desc = product.novaDescription {
                    HStack(spacing: 4) {
                        Text("NOVA \(nova)")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(novaColor(nova).opacity(0.18))
                            .foregroundStyle(novaColor(nova))
                            .clipShape(Capsule())
                        Text(desc)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.prDivider, lineWidth: 0.5)
        )
    }

    private func novaColor(_ group: Int) -> Color {
        switch group {
        case 1: return .green
        case 2: return .mint
        case 3: return .orange
        case 4: return .red
        default: return .gray
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredients list")
                .font(.headline)

            ZStack(alignment: .topLeading) {
                if inputText.isEmpty {
                    Text("e.g. Sugar, enriched wheat flour, soybean oil, red 40, BHT…")
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                TextEditor(text: $inputText)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
            }
            .padding(8)
            .background(Color.prInputField)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack {
                Button {
                    inputText = IngredientAnalyzer.exampleLabel
                } label: {
                    Label("Load example", systemImage: "doc.text")
                        .font(.footnote)
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    analyze()
                } label: {
                    Label("Analyze", systemImage: "sparkles")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.prDivider, lineWidth: 0.5)
        )
    }

    private func verdictBadge(_ analysis: IngredientAnalysis) -> some View {
        let verdict = analysis.verdict
        return HStack(spacing: 14) {
            Image(systemName: verdict.systemImage)
                .font(.system(size: 34))
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(verdict.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(analysis.verdictReason)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(verdict.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func carcinogenBanner(_ analysis: IngredientAnalysis) -> some View {
        let detected = analysis.carcinogensDetected
        let highest = detected.map { $0.level }.max(by: { lhs, rhs in
            order(lhs) < order(rhs)
        }) ?? .possible
        let names = detected.map { $0.name }.joined(separator: ", ")

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text(highest.shortLabel + " detected")
                    .font(.headline)
                    .foregroundStyle(.red)
            }
            Text(names)
                .font(.footnote)
                .foregroundStyle(.primary)
            Text(highest.fullLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Link(destination: Citations.iarcURL) {
                Label("Source: IARC Monographs (WHO)", systemImage: "link")
                    .font(.caption2.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.4), lineWidth: 1)
        )
    }

    private func contaminantExposureCard(_ analysis: IngredientAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "drop.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Likely contaminant exposure")
                    .font(.headline)
                    .foregroundStyle(.orange)
            }
            Text("Inferred from conventional ingredients and packaging. Choose organic or verified residue-free alternatives to avoid.")
                .font(.caption2)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(analysis.contaminantExposures) { exposure in
                    contaminantRow(exposure)
                }
            }

            Link(destination: Citations.usdaPDPURL) {
                Label("Source: USDA Pesticide Data Program", systemImage: "link")
                    .font(.caption2.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.4), lineWidth: 1)
        )
    }

    private func contaminantRow(_ exposure: ContaminantExposure) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(exposure.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if exposure.carcinogen.isAny {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            Text("Triggered by: \(exposure.triggeredBy)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(exposure.detail)
                .font(.footnote)
                .foregroundStyle(.primary)
            if exposure.carcinogen.isAny {
                Text(exposure.carcinogen.fullLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.red)
            }
            let citation = Citations.source(forExposureTitle: exposure.title)
            Link(destination: citation.url) {
                Label("Source: \(citation.label)", systemImage: "link")
                    .font(.caption2.weight(.semibold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func order(_ c: CarcinogenClass) -> Int {
        switch c {
        case .none: return 0
        case .possible: return 1
        case .probable: return 2
        case .known: return 3
        }
    }

    private func scoreCard(_ analysis: IngredientAnalysis) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle().fill(analysis.gradeColor.opacity(0.15))
                Circle().stroke(analysis.gradeColor, lineWidth: 4)
                VStack(spacing: 0) {
                    Text("\(analysis.score)")
                        .font(.system(size: 32, weight: .bold))
                    Text("/ 100")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: 4) {
                Text("Grade \(analysis.grade)")
                    .font(.title.bold())
                    .foregroundStyle(analysis.gradeColor)
                Text(verdict(for: analysis))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button {
                    showSources = true
                } label: {
                    Label("Sources & citations", systemImage: "books.vertical")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding()
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(Color.prDivider, lineWidth: 0.5)
        )
    }

    private func summaryStrip(_ analysis: IngredientAnalysis) -> some View {
        HStack(spacing: 8) {
            countTile(value: analysis.avoidCount, label: "Avoid", color: .red)
            countTile(value: analysis.cautionCount, label: "Caution", color: .orange)
            countTile(value: analysis.cleanCount, label: "Clean", color: .green)
            countTile(value: analysis.unknownCount, label: "Unknown", color: .gray)
        }
    }

    private func countTile(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func ingredientsList(_ analysis: IngredientAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Breakdown")
                .font(.headline)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(analysis.ingredients) { ingredient in
                    ingredientRow(ingredient)
                }
            }
        }
    }

    private func ingredientRow(_ ingredient: AnalyzedIngredient) -> some View {
        let isExpanded = expandedID == ingredient.id
        let canExpand = ingredient.entry != nil

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                guard canExpand else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedID = isExpanded ? nil : ingredient.id
                }
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(ingredient.risk.color)
                        .frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(ingredient.displayName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            if let entry = ingredient.entry, entry.carcinogen.isAny {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                        if ingredient.isUnknown {
                            Text("Not in database")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text(ingredient.risk.label)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ingredient.risk.color.opacity(0.15))
                        .foregroundStyle(ingredient.risk.color)
                        .clipShape(Capsule())
                    if canExpand {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
            }
            .buttonStyle(.plain)
            .disabled(!canExpand)

            if isExpanded, let entry = ingredient.entry {
                VStack(alignment: .leading, spacing: 10) {
                    if entry.carcinogen.isAny {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(entry.carcinogen.fullLabel)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.red)
                        }
                    }
                    detailRow(title: "Health concern", body: entry.concern)
                    detailRow(title: "Why it's used", body: entry.purpose)
                    if entry.alternative != "—" && !entry.alternative.isEmpty {
                        detailRow(title: "Clean alternative", body: entry.alternative)
                    }
                    let citation = Citations.source(for: entry)
                    Link(destination: citation.url) {
                        Label("Source: \(citation.label)", systemImage: "link")
                            .font(.caption2.weight(.semibold))
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.prDivider, lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private var saferAlternativesCard: some View {
        let category = SaferAlternatives.inferCategory(from: inputText)
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text("Try a cleaner alternative")
                    .font(.headline)
            }
            Text("This product scored poorly. Here's a hand-vetted option that avoids the additives and contaminants above.")
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let brand = SaferAlternatives.namedBrand(for: category) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(brand.name)
                        .font(.subheadline.weight(.semibold))
                    Text(brand.highlight)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if let url = URL(string: brand.url) {
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Text("Visit \(brand.name)")
                                    .font(.footnote.weight(.semibold))
                                Image(systemName: "arrow.up.right.square")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.prCard)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button {
                alternativesCategory = category
            } label: {
                HStack {
                    Text("Browse clean \(category.rawValue) options")
                        .font(.footnote.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.12))
                .foregroundStyle(.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.green.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.green.opacity(0.35), lineWidth: 1)
        )
    }

    private var sourcesSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Risk ratings, carcinogen classifications, and residue information in PureRootFood are based on the following public sources. Each flagged ingredient in a report also links directly to the source for its specific claim.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    sourcesCard
                }
                .padding()
            }
            .navigationTitle("Sources & Citations")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showSources = false }
                }
            }
        }
    }

    private var sourcesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "books.vertical.fill")
                    .foregroundStyle(.green)
                Text("Sources & Citations")
                    .font(.headline)
            }
            Text("Risk ratings, carcinogen classifications, and residue information in this report are based on the following public sources:")
                .font(.caption2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Citations.all) { source in
                    Link(destination: source.url) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "link")
                                .font(.caption2)
                                .foregroundStyle(.green)
                                .padding(.top, 3)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(source.name)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.green)
                                Text(source.detail)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }

            Text(Citations.disclaimer)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.prDivider, lineWidth: 0.5)
        )
    }

    private func detailRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(body)
                .font(.footnote)
                .foregroundStyle(.primary)
        }
    }

    private func analyze() {
        withAnimation { analysis = IngredientAnalyzer.analyze(inputText) }
        expandedID = nil
    }

    private func lookupBarcode(_ code: String) async {
        productLookupInFlight = true
        productLookupError = nil
        defer { productLookupInFlight = false }

        do {
            let product = try await OpenFoodFactsClient.fetch(barcode: code)
            scannedProduct = product
            if let ingredients = product.ingredients_text, !ingredients.isEmpty {
                inputText = ingredients
                analyze()
            } else {
                productLookupError = "Product found but it has no ingredient list in the database."
            }
        } catch {
            productLookupError = error.localizedDescription
        }
    }

    private func verdict(for analysis: IngredientAnalysis) -> String {
        switch analysis.grade {
        case "A": return "Excellent — mostly clean ingredients."
        case "B": return "Good — a few concerns to be aware of."
        case "C": return "Mixed bag — several ingredients to watch."
        case "D": return "Concerning — many problematic ingredients."
        default: return "Avoid — multiple harmful ingredients detected."
        }
    }
}

#Preview {
    IngredientScannerView()
}
