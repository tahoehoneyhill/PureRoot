//
//  SaferAlternatives.swift
//  PureRoot
//

import Foundation

/// Suggests a safer product to buy instead when an analysis scores poorly.
/// Named suggestions are drawn from the app's own hand-vetted shipper
/// directory (`ShipperData`) so there is a single, maintained source of truth.
enum SaferAlternatives {

    /// Whether a safer-alternative suggestion should be offered for this result.
    static func shouldSuggest(for analysis: IngredientAnalysis) -> Bool {
        if analysis.grade == "D" || analysis.grade == "F" || analysis.avoidCount > 0 {
            return true
        }
        if analysis.hasCarcinogens { return true }
        return analysis.contaminantExposures.contains { $0.carcinogen.isAny }
    }

    /// Infers the most relevant clean-shopping category from the ingredient text.
    static func inferCategory(from ingredientsText: String) -> ShipperCategory {
        let low = ingredientsText.lowercased()
        func hasAny(_ words: [String]) -> Bool { words.contains { low.contains($0) } }

        if hasAny(["protein powder", "protein isolate", "collagen", "creatine", "supplement", "vitamin"]) {
            return .snacks
        }
        if hasAny(["beef", "chicken", "pork", "turkey", "bacon", "sausage", "salmon", "tuna", "fish", "seafood", "meat", "poultry"]) {
            return .meatSeafood
        }
        if hasAny(["chips", "cracker", "cookie", "candy", "chocolate", "bar", "snack", "popcorn", "pretzel", "cocoa", "cacao"]) {
            return .snacks
        }
        if hasAny(["lettuce", "spinach", "kale", "apple", "banana", "berry", "tomato", "carrot", "produce", "vegetable", "fruit"]) {
            return .produce
        }
        if hasAny(["flour", "grain", "oat", "rice", "bean", "pasta", "cereal", "bread", "wheat"]) {
            return .bulk
        }
        return .grocery
    }

    /// A confident named clean-brand suggestion for a category, taken from the
    /// vetted directory. Falls back to a general grocery pick.
    static func namedBrand(for category: ShipperCategory) -> Shipper? {
        ShipperData.all.first { $0.category == category }
            ?? ShipperData.all.first { $0.category == .grocery }
            ?? ShipperData.all.first
    }
}
