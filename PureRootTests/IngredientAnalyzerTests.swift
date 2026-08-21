//
//  IngredientAnalyzerTests.swift
//  PureRootTests
//

import Testing
@testable import PureRoot

struct IngredientAnalyzerTests {

    // MARK: - Word-boundary matcher

    @Test("Matcher rejects substring false positives")
    func matcherRejectsFalsePositives() {
        #expect(IngredientAnalyzer.matches("unsalted butter", term: "salt") == false)
        #expect(IngredientAnalyzer.matches("sugar-free gum", term: "sugar") == false)
        #expect(IngredientAnalyzer.matches("licorice root", term: "rice") == false)
        #expect(IngredientAnalyzer.matches("black peppercorn", term: "corn") == false)
    }

    @Test("Matcher accepts real whole-word matches")
    func matcherAcceptsRealMatches() {
        #expect(IngredientAnalyzer.matches("sea salt", term: "salt"))
        #expect(IngredientAnalyzer.matches("brown rice flour", term: "rice"))
        #expect(IngredientAnalyzer.matches("organic corn syrup", term: "corn"))
        #expect(IngredientAnalyzer.matches("high fructose corn syrup", term: "high fructose corn syrup"))
    }

    @Test("Empty term never matches")
    func matcherEmptyTerm() {
        #expect(IngredientAnalyzer.matches("anything", term: "") == false)
    }

    // MARK: - Ingredient database resolution

    @Test("unsalted butter does not resolve to the Salt entry")
    func unsaltedNotFlaggedAsSalt() {
        let analysis = IngredientAnalyzer.analyze("unsalted butter")
        #expect(!analysis.ingredients.contains { $0.entry?.canonicalName == "Salt" })
    }

    @Test("Sodium nitrite is flagged as a known carcinogen")
    func sodiumNitriteIsKnownCarcinogen() {
        let analysis = IngredientAnalyzer.analyze("sodium nitrite")
        #expect(analysis.hasCarcinogens)
        #expect(analysis.carcinogensDetected.contains { $0.level == .known })
    }

    // MARK: - Verdicts

    @Test("Clean ingredients yield a clean verdict")
    func cleanVerdict() {
        let analysis = IngredientAnalyzer.analyze("water, sea salt, olive oil")
        #expect(analysis.verdict == .clean)
        #expect(analysis.grade == "A")
    }

    @Test("Multiple harmful ingredients yield an avoid verdict")
    func avoidVerdict() {
        let analysis = IngredientAnalyzer.analyze("sugar, red 40, BHT, sodium nitrite, partially hydrogenated soybean oil")
        #expect(analysis.verdict == .avoid)
    }

    // MARK: - Heavy-metal contaminant inference

    @Test("Rice triggers an inorganic arsenic exposure")
    func riceTriggersArsenic() {
        let analysis = IngredientAnalyzer.analyze("white rice")
        #expect(analysis.contaminantExposures.contains { $0.title.lowercased().contains("arsenic") })
    }

    @Test("Cocoa triggers a lead & cadmium exposure")
    func cocoaTriggersLeadCadmium() {
        let analysis = IngredientAnalyzer.analyze("cocoa")
        #expect(analysis.contaminantExposures.contains { $0.title.lowercased().contains("cadmium") })
    }

    @Test("Tuna triggers a methylmercury exposure")
    func tunaTriggersMercury() {
        let analysis = IngredientAnalyzer.analyze("tuna")
        #expect(analysis.contaminantExposures.contains { $0.title.lowercased().contains("mercury") })
    }

    // MARK: - Organic exemption

    @Test("Organic grain is exempt from the glyphosate residue inference")
    func organicExemption() {
        let conventional = IngredientAnalyzer.analyze("wheat flour")
        let organic = IngredientAnalyzer.analyze("organic wheat flour")
        #expect(conventional.contaminantExposures.contains { $0.title.lowercased().contains("glyphosate") })
        #expect(!organic.contaminantExposures.contains { $0.title.lowercased().contains("glyphosate") })
    }

    // MARK: - Citations

    @Test("Every heavy-metal exposure resolves to a citation URL")
    func heavyMetalExposuresHaveCitations() {
        let analysis = IngredientAnalyzer.analyze("white rice, cocoa, tuna, cinnamon")
        #expect(!analysis.contaminantExposures.isEmpty)
        for exposure in analysis.contaminantExposures {
            let citation = Citations.source(forExposureTitle: exposure.title)
            #expect(!citation.label.isEmpty)
        }
    }

    @Test("Every flagged ingredient resolves to a citation URL")
    func flaggedIngredientsHaveCitations() {
        let analysis = IngredientAnalyzer.analyze("red 40, BHT, aspartame, glyphosate")
        for ingredient in analysis.ingredients {
            if let entry = ingredient.entry {
                let citation = Citations.source(for: entry)
                #expect(!citation.label.isEmpty)
            }
        }
    }
}
