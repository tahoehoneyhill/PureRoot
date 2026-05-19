//
//  IngredientAnalyzer.swift
//  PureRoot
//

import Foundation
import SwiftUI

enum IngredientRisk: String, Codable {
    case avoid
    case caution
    case moderate
    case safe
    case clean

    var label: String {
        switch self {
        case .avoid: return "Avoid"
        case .caution: return "Caution"
        case .moderate: return "Moderate"
        case .safe: return "Safe"
        case .clean: return "Clean"
        }
    }

    var color: Color {
        switch self {
        case .avoid: return .red
        case .caution: return .orange
        case .moderate: return .yellow
        case .safe: return .mint
        case .clean: return .green
        }
    }

    var scoreDelta: Int {
        switch self {
        case .avoid: return -15
        case .caution: return -8
        case .moderate: return -4
        case .safe: return 0
        case .clean: return 1
        }
    }
}

enum CarcinogenClass: String {
    case none
    case possible
    case probable
    case known

    var isAny: Bool { self != .none }

    var shortLabel: String {
        switch self {
        case .none: return ""
        case .possible: return "Possible carcinogen"
        case .probable: return "Probable carcinogen"
        case .known: return "Known carcinogen"
        }
    }

    var fullLabel: String {
        switch self {
        case .none: return ""
        case .possible: return "Possible carcinogen (IARC Group 2B)"
        case .probable: return "Probable carcinogen (IARC Group 2A)"
        case .known: return "Known carcinogen (IARC Group 1)"
        }
    }

    var color: Color {
        switch self {
        case .none: return .gray
        case .possible: return .orange
        case .probable: return .red
        case .known: return .red
        }
    }
}

struct IngredientEntry {
    let canonicalName: String
    let aliases: [String]
    let risk: IngredientRisk
    let concern: String
    let purpose: String
    let alternative: String
    let carcinogen: CarcinogenClass

    init(canonicalName: String,
         aliases: [String],
         risk: IngredientRisk,
         concern: String,
         purpose: String,
         alternative: String,
         carcinogen: CarcinogenClass = .none) {
        self.canonicalName = canonicalName
        self.aliases = aliases
        self.risk = risk
        self.concern = concern
        self.purpose = purpose
        self.alternative = alternative
        self.carcinogen = carcinogen
    }
}

struct AnalyzedIngredient: Identifiable {
    let id = UUID()
    let raw: String
    let entry: IngredientEntry?

    var displayName: String {
        entry?.canonicalName ?? raw.capitalized
    }

    var risk: IngredientRisk {
        entry?.risk ?? .moderate
    }

    var isUnknown: Bool { entry == nil }
}

struct IngredientAnalysis {
    let score: Int
    let grade: String
    let ingredients: [AnalyzedIngredient]

    var avoidCount: Int { ingredients.filter { $0.risk == .avoid }.count }
    var cautionCount: Int { ingredients.filter { $0.risk == .caution }.count }
    var cleanCount: Int { ingredients.filter { $0.risk == .clean || $0.risk == .safe }.count }
    var unknownCount: Int { ingredients.filter { $0.isUnknown }.count }

    var carcinogensDetected: [(name: String, level: CarcinogenClass)] {
        ingredients.compactMap { ing in
            guard let entry = ing.entry, entry.carcinogen.isAny else { return nil }
            return (entry.canonicalName, entry.carcinogen)
        }
    }

    var hasCarcinogens: Bool { !carcinogensDetected.isEmpty }

    var gradeColor: Color {
        switch grade {
        case "A": return .green
        case "B": return .mint
        case "C": return .yellow
        case "D": return .orange
        default: return .red
        }
    }
}

enum IngredientAnalyzer {
    static let exampleLabel = "Sugar, enriched wheat flour, high fructose corn syrup, partially hydrogenated soybean oil, salt, baking soda, sodium aluminum phosphate, soy lecithin, mono and diglycerides, natural and artificial flavors, red 40, yellow 5, BHT, citric acid"

    static let database: [IngredientEntry] = [
        IngredientEntry(canonicalName: "High Fructose Corn Syrup", aliases: ["hfcs", "high-fructose corn syrup"], risk: .avoid,
                        concern: "Linked to obesity, fatty liver disease, insulin resistance, and metabolic syndrome.",
                        purpose: "Cheap sweetener that extends shelf life and adds bulk.",
                        alternative: "Organic cane sugar, maple syrup, raw honey, or dates."),
        IngredientEntry(canonicalName: "Partially Hydrogenated Oil", aliases: ["partially hydrogenated", "trans fat"], risk: .avoid,
                        concern: "Trans fats — directly linked to heart disease. Banned by the FDA in 2018 but still appears in some products.",
                        purpose: "Improves texture and extends shelf life.",
                        alternative: "Cold-pressed olive oil, avocado oil, or grass-fed butter."),
        IngredientEntry(canonicalName: "BHA", aliases: ["butylated hydroxyanisole"], risk: .avoid,
                        concern: "Listed by the National Toxicology Program as 'reasonably anticipated to be a human carcinogen.'",
                        purpose: "Synthetic preservative that prevents fats from going rancid.",
                        alternative: "Vitamin E (tocopherols) or rosemary extract.",
                        carcinogen: .possible),
        IngredientEntry(canonicalName: "BHT", aliases: ["butylated hydroxytoluene"], risk: .avoid,
                        concern: "Possible endocrine disruptor and tumor promoter in animal studies.",
                        purpose: "Synthetic preservative similar to BHA.",
                        alternative: "Vitamin E or rosemary extract.",
                        carcinogen: .possible),
        IngredientEntry(canonicalName: "TBHQ", aliases: ["tertiary butylhydroquinone"], risk: .avoid,
                        concern: "Linked to immune system dysfunction and behavioral effects in studies.",
                        purpose: "Synthetic preservative used in processed foods and frying oils.",
                        alternative: "Natural antioxidants like vitamin E."),
        IngredientEntry(canonicalName: "Sodium Nitrite", aliases: ["sodium nitrate"], risk: .avoid,
                        concern: "Forms nitrosamines when heated — Group 1 IARC carcinogen when used in processed meats.",
                        purpose: "Preserves color and prevents botulism in cured meats.",
                        alternative: "Uncured meats preserved with celery powder and sea salt.",
                        carcinogen: .known),
        IngredientEntry(canonicalName: "Red 40", aliases: ["red dye 40", "allura red"], risk: .avoid,
                        concern: "Linked to hyperactivity in children. Banned or warning-labeled in much of Europe.",
                        purpose: "Petroleum-derived artificial coloring.",
                        alternative: "Beet juice, paprika extract, or annatto."),
        IngredientEntry(canonicalName: "Yellow 5", aliases: ["yellow dye 5", "tartrazine"], risk: .avoid,
                        concern: "Allergen and hyperactivity trigger. Requires warning labels in the EU.",
                        purpose: "Petroleum-derived artificial coloring.",
                        alternative: "Turmeric or annatto."),
        IngredientEntry(canonicalName: "Yellow 6", aliases: ["yellow dye 6", "sunset yellow"], risk: .avoid,
                        concern: "May contain carcinogenic contaminants. Hyperactivity link in children.",
                        purpose: "Petroleum-derived artificial coloring.",
                        alternative: "Turmeric, saffron, or annatto."),
        IngredientEntry(canonicalName: "Blue 1", aliases: ["blue dye 1", "brilliant blue"], risk: .avoid,
                        concern: "Petroleum-based dye, hyperactivity concerns in children.",
                        purpose: "Artificial blue coloring.",
                        alternative: "Spirulina extract or red cabbage."),
        IngredientEntry(canonicalName: "Titanium Dioxide", aliases: [], risk: .avoid,
                        concern: "Banned in the EU in 2022 over DNA damage concerns. Still allowed in US foods.",
                        purpose: "Whitens and brightens candies, dairy, and powdered foods.",
                        alternative: "Avoid products that need to look unnaturally white.",
                        carcinogen: .possible),
        IngredientEntry(canonicalName: "Aspartame", aliases: [], risk: .caution,
                        concern: "Classified as 'possibly carcinogenic to humans' by the WHO in 2023.",
                        purpose: "Artificial sweetener.",
                        alternative: "Stevia, monk fruit, or raw honey in moderation.",
                        carcinogen: .possible),
        IngredientEntry(canonicalName: "Sucralose", aliases: ["splenda"], risk: .caution,
                        concern: "May disrupt gut microbiome and produce harmful compounds when heated.",
                        purpose: "Zero-calorie artificial sweetener.",
                        alternative: "Stevia or monk fruit."),
        IngredientEntry(canonicalName: "Acesulfame Potassium", aliases: ["acesulfame k", "ace-k"], risk: .caution,
                        concern: "Animal studies suggest possible carcinogenicity; long-term human data is limited.",
                        purpose: "Artificial sweetener, often blended with others.",
                        alternative: "Stevia or monk fruit."),
        IngredientEntry(canonicalName: "MSG", aliases: ["monosodium glutamate"], risk: .caution,
                        concern: "Triggers headaches and other symptoms in sensitive individuals.",
                        purpose: "Flavor enhancer.",
                        alternative: "Mushrooms, tomatoes, parmesan, or sea salt for umami."),
        IngredientEntry(canonicalName: "Carrageenan", aliases: [], risk: .caution,
                        concern: "Linked to gut inflammation. Degraded form is a known carcinogen.",
                        purpose: "Thickener and stabilizer derived from seaweed.",
                        alternative: "Agar, guar gum, or no thickener at all."),
        IngredientEntry(canonicalName: "Propylene Glycol", aliases: [], risk: .caution,
                        concern: "Industrial solvent also used in antifreeze. Generally safe but a known irritant.",
                        purpose: "Moisture retainer and texture aid.",
                        alternative: "Glycerin from natural sources."),
        IngredientEntry(canonicalName: "Sodium Benzoate", aliases: [], risk: .caution,
                        concern: "Forms benzene (a carcinogen) when combined with vitamin C.",
                        purpose: "Preservative.",
                        alternative: "Citric acid or refrigeration."),
        IngredientEntry(canonicalName: "Polysorbate 80", aliases: [], risk: .caution,
                        concern: "May alter gut microbiome and contribute to inflammation.",
                        purpose: "Emulsifier.",
                        alternative: "Sunflower lecithin or no emulsifier."),
        IngredientEntry(canonicalName: "Mono and Diglycerides", aliases: ["monoglycerides", "diglycerides"], risk: .caution,
                        concern: "Often contain hidden trans fats; not subject to trans fat labeling rules.",
                        purpose: "Emulsifier in baked goods.",
                        alternative: "Sunflower lecithin or natural egg yolk emulsion."),
        IngredientEntry(canonicalName: "Caramel Color", aliases: ["caramel coloring"], risk: .caution,
                        concern: "Class III and IV varieties contain 4-MEI, a possible carcinogen.",
                        purpose: "Brown coloring agent.",
                        alternative: "Real caramelized sugar or molasses.",
                        carcinogen: .possible),
        IngredientEntry(canonicalName: "Natural Flavors", aliases: ["natural flavoring"], risk: .caution,
                        concern: "Vague catch-all — can hide dozens of undisclosed chemicals and solvents.",
                        purpose: "Proprietary flavor blend.",
                        alternative: "Whole spices, herbs, and real ingredients.") ,
        IngredientEntry(canonicalName: "Artificial Flavors", aliases: ["artificial flavoring"], risk: .caution,
                        concern: "Synthetic blends with undisclosed components.",
                        purpose: "Lab-created flavor profile.",
                        alternative: "Real whole-food ingredients."),
        IngredientEntry(canonicalName: "Soybean Oil", aliases: [], risk: .caution,
                        concern: "Highly processed seed oil; linked to inflammation when consumed in excess.",
                        purpose: "Cheap industrial cooking oil.",
                        alternative: "Olive oil, avocado oil, or coconut oil."),
        IngredientEntry(canonicalName: "Canola Oil", aliases: ["rapeseed oil"], risk: .caution,
                        concern: "Typically GMO and chemically extracted with hexane.",
                        purpose: "Industrial cooking oil.",
                        alternative: "Cold-pressed olive oil or avocado oil."),
        IngredientEntry(canonicalName: "Corn Oil", aliases: [], risk: .caution,
                        concern: "Highly processed, high in inflammatory omega-6 fats.",
                        purpose: "Industrial cooking oil.",
                        alternative: "Olive oil, avocado oil, or grass-fed butter."),
        IngredientEntry(canonicalName: "Maltodextrin", aliases: [], risk: .moderate,
                        concern: "Spikes blood sugar more than table sugar; often GMO-derived.",
                        purpose: "Filler, thickener, and texture aid.",
                        alternative: "Tapioca starch or no filler."),
        IngredientEntry(canonicalName: "Modified Food Starch", aliases: ["modified corn starch"], risk: .moderate,
                        concern: "Often GMO, chemically processed; specific source not always disclosed.",
                        purpose: "Thickener and stabilizer.",
                        alternative: "Arrowroot or tapioca starch."),
        IngredientEntry(canonicalName: "Soy Lecithin", aliases: [], risk: .moderate,
                        concern: "Usually derived from GMO soy with chemical solvents.",
                        purpose: "Emulsifier.",
                        alternative: "Sunflower lecithin."),
        IngredientEntry(canonicalName: "Cellulose Gum", aliases: ["carboxymethyl cellulose", "cmc"], risk: .moderate,
                        concern: "Emerging research links it to gut microbiome disruption.",
                        purpose: "Thickener and stabilizer.",
                        alternative: "Natural gums or no thickener."),
        IngredientEntry(canonicalName: "Sodium Phosphate", aliases: ["sodium aluminum phosphate", "monocalcium phosphate"], risk: .moderate,
                        concern: "Phosphate additives linked to kidney and cardiovascular issues with chronic exposure.",
                        purpose: "Leavening or emulsifier in baked and processed foods.",
                        alternative: "Traditional baking with cream of tartar or yeast."),
        IngredientEntry(canonicalName: "Potassium Sorbate", aliases: [], risk: .moderate,
                        concern: "Generally safe but can cause sensitivity reactions in some people.",
                        purpose: "Mold and yeast inhibitor preservative.",
                        alternative: "Vinegar, salt, or refrigeration."),
        IngredientEntry(canonicalName: "Calcium Propionate", aliases: [], risk: .moderate,
                        concern: "Linked to behavioral changes in sensitive children in some studies.",
                        purpose: "Mold inhibitor in baked goods.",
                        alternative: "Fresh baked goods or sourdough fermentation."),
        IngredientEntry(canonicalName: "Enriched Wheat Flour", aliases: ["enriched flour", "bleached flour"], risk: .moderate,
                        concern: "Stripped of bran and germ, then synthetically 'enriched' with isolated nutrients.",
                        purpose: "Standard processed flour.",
                        alternative: "Whole grain, freshly milled, or sprouted flours."),
        IngredientEntry(canonicalName: "Sugar", aliases: ["cane sugar", "evaporated cane juice"], risk: .moderate,
                        concern: "Excess intake drives chronic disease and metabolic dysfunction.",
                        purpose: "Sweetener.",
                        alternative: "Raw honey, maple syrup, or whole fruit in moderation."),
        IngredientEntry(canonicalName: "Xanthan Gum", aliases: [], risk: .safe,
                        concern: "Generally well tolerated; can cause digestive upset in large amounts.",
                        purpose: "Thickener and stabilizer.",
                        alternative: "Often unnecessary in scratch cooking."),
        IngredientEntry(canonicalName: "Guar Gum", aliases: [], risk: .safe,
                        concern: "Plant-based and generally well tolerated.",
                        purpose: "Thickener.",
                        alternative: "—"),
        IngredientEntry(canonicalName: "Citric Acid", aliases: [], risk: .safe,
                        concern: "Generally safe, though often produced via industrial mold fermentation.",
                        purpose: "Preservative and acidifier.",
                        alternative: "Lemon juice."),
        IngredientEntry(canonicalName: "Ascorbic Acid", aliases: ["vitamin c"], risk: .safe,
                        concern: "Synthetic vitamin C, generally safe.",
                        purpose: "Preservative and antioxidant.",
                        alternative: "Whole-food vitamin C sources."),
        IngredientEntry(canonicalName: "Salt", aliases: ["sea salt", "kosher salt"], risk: .safe,
                        concern: "Watch sodium totals; quality varies between refined and unrefined.",
                        purpose: "Seasoning and preservative.",
                        alternative: "Mineral-rich sea or Himalayan salt."),
        IngredientEntry(canonicalName: "Baking Soda", aliases: ["sodium bicarbonate"], risk: .safe,
                        concern: "Inert mineral, safe in food amounts.",
                        purpose: "Leavening agent.",
                        alternative: "—"),
        IngredientEntry(canonicalName: "Water", aliases: ["filtered water"], risk: .clean,
                        concern: "—",
                        purpose: "Base ingredient.",
                        alternative: "—"),
        IngredientEntry(canonicalName: "Organic", aliases: ["organic "], risk: .clean,
                        concern: "Certified organic ingredients are grown without synthetic pesticides or GMOs.",
                        purpose: "Whole-food ingredient.",
                        alternative: "—"),
        IngredientEntry(canonicalName: "Olive Oil", aliases: ["extra virgin olive oil"], risk: .clean,
                        concern: "Check for genuine cold-pressed; some commercial olive oils are cut with seed oils.",
                        purpose: "Healthy fat source.",
                        alternative: "—"),
        IngredientEntry(canonicalName: "Honey", aliases: ["raw honey"], risk: .clean,
                        concern: "Raw and local is best; ultra-filtered honey loses most of its benefits.",
                        purpose: "Natural sweetener.",
                        alternative: "—"),
        IngredientEntry(canonicalName: "Maple Syrup", aliases: ["pure maple syrup"], risk: .clean,
                        concern: "Choose 'pure' — not pancake syrup, which is HFCS with flavoring.",
                        purpose: "Natural sweetener.",
                        alternative: "—"),
    ]

    static func analyze(_ text: String) -> IngredientAnalysis {
        let separators = CharacterSet(charactersIn: ",;()[]")
        let raws = text
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count < 80 }

        let lowered = raws.map { ($0, $0.lowercased()) }

        let ingredients: [AnalyzedIngredient] = lowered.map { raw, low in
            let entry = database.first { entry in
                if low.contains(entry.canonicalName.lowercased()) { return true }
                return entry.aliases.contains { !$0.isEmpty && low.contains($0.lowercased()) }
            }
            return AnalyzedIngredient(raw: raw, entry: entry)
        }

        var score = 100
        for ing in ingredients {
            if let entry = ing.entry {
                score += entry.risk.scoreDelta
            } else {
                score -= 1
            }
        }
        score = max(0, min(100, score))

        let grade: String
        switch score {
        case 90...100: grade = "A"
        case 80..<90: grade = "B"
        case 70..<80: grade = "C"
        case 60..<70: grade = "D"
        default: grade = "F"
        }

        return IngredientAnalysis(score: score, grade: grade, ingredients: ingredients)
    }
}
