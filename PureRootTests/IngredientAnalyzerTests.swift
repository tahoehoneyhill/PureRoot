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

    // MARK: - PFAS / forever-chemical inference

    @Test("PFAS-lined packaging triggers a PFAS exposure")
    func microwavePopcornTriggersPFAS() {
        let analysis = IngredientAnalyzer.analyze("microwave popcorn")
        #expect(analysis.contaminantExposures.contains { $0.title.lowercased().contains("pfas") })
    }

    @Test("Seafood, bottled water, and leafy greens each infer PFAS")
    func foodCategoriesTriggerPFAS() {
        for label in ["salmon", "spring water", "spinach"] {
            let analysis = IngredientAnalyzer.analyze(label)
            #expect(
                analysis.contaminantExposures.contains { $0.title.lowercased().contains("pfas") },
                "Expected a PFAS exposure for \(label)"
            )
        }
    }

    @Test("Every PFAS exposure resolves to the ATSDR citation")
    func pfasExposuresCiteATSDR() {
        let analysis = IngredientAnalyzer.analyze("salmon, spring water, spinach, microwave popcorn")
        let pfas = analysis.contaminantExposures.filter { $0.title.lowercased().contains("pfas") }
        #expect(!pfas.isEmpty)
        for exposure in pfas {
            let citation = Citations.source(forExposureTitle: exposure.title)
            #expect(citation.label.contains("ATSDR"))
        }
    }

    // MARK: - Weighted scoring (takes everything into account)

    @Test("Carcinogen certainty is ordered by score penalty")
    func carcinogenPenaltyOrdering() {
        #expect(CarcinogenClass.none.scorePenalty == 0)
        #expect(CarcinogenClass.possible.scorePenalty < CarcinogenClass.probable.scorePenalty)
        #expect(CarcinogenClass.probable.scorePenalty < CarcinogenClass.known.scorePenalty)
    }

    @Test("A known-carcinogen exposure penalizes more than a benign one")
    func exposurePenaltyReflectsCarcinogen() {
        let known = ContaminantExposure(title: "x", triggeredBy: "y", detail: "z",
                                        risk: .caution, carcinogen: .known)
        let benign = ContaminantExposure(title: "x", triggeredBy: "y", detail: "z",
                                         risk: .caution, carcinogen: .none)
        #expect(known.penalty > benign.penalty)
    }

    @Test("Contaminant exposures actually pull the score down")
    func exposuresLowerScore() {
        // Rice carries a known-carcinogen (arsenic) inference, so it must not
        // score as a perfect 100 the way an inert unknown would.
        let rice = IngredientAnalyzer.analyze("white rice")
        #expect(rice.score < 95)
    }

    @Test("More contaminants means a strictly lower score")
    func moreContaminantsScoreLower() {
        let one = IngredientAnalyzer.analyze("white rice")
        let many = IngredientAnalyzer.analyze("white rice, tuna, wheat flour, cocoa")
        #expect(many.score < one.score)
    }

    // MARK: - Shopper scorecard

    @Test("Scorecard always answers the four shopper questions")
    func scorecardHasFourChecks() {
        let analysis = IngredientAnalyzer.analyze("water, sea salt")
        #expect(analysis.shopperChecks.count == 4)
    }

    @Test("A clean organic product passes the safety and chemical checks")
    func cleanProductPassesChecks() {
        let analysis = IngredientAnalyzer.analyze("organic olive oil, raw honey")
        let checks = analysis.shopperChecks
        #expect(checks[0].status == .yes) // Is it safe to eat?
        #expect(checks[2].status == .yes) // Limits dangerous chemicals?
        #expect(analysis.hasOrganic)
    }

    @Test("A carcinogen product fails the safety and chemical checks")
    func harmfulProductFailsChecks() {
        let analysis = IngredientAnalyzer.analyze("sugar, red 40, BHT, sodium nitrite")
        let checks = analysis.shopperChecks
        #expect(checks[0].status == .no) // Is it safe to eat?
        #expect(checks[2].status == .no) // Limits dangerous chemicals?
    }

    // MARK: - Ultra-processed (NOVA 4) detection

    @Test("NOVA group 4 marks a product ultra-processed")
    func novaFourIsUltraProcessed() {
        let analysis = IngredientAnalyzer.analyze("tomatoes, water, salt", novaGroup: 4)
        #expect(analysis.isUltraProcessed)
    }

    @Test("A single strong industrial marker flags ultra-processing from text")
    func strongMarkerFlagsUPF() {
        let analysis = IngredientAnalyzer.analyze("water, maltodextrin, salt")
        #expect(analysis.isUltraProcessed)
    }

    @Test("A whole-food ingredient list is not ultra-processed")
    func wholeFoodNotUPF() {
        let analysis = IngredientAnalyzer.analyze("organic rolled oats, water, cinnamon")
        #expect(!analysis.isUltraProcessed)
    }

    @Test("One moderate marker alone does not flag ultra-processing")
    func singleModerateMarkerNotUPF() {
        let analysis = IngredientAnalyzer.analyze("chickpeas, water, sea salt, citric acid")
        #expect(!analysis.isUltraProcessed)
    }

    @Test("Ultra-processing lowers the score and the good-for-you check")
    func upfLowersScoreAndCheck() {
        let plain = IngredientAnalyzer.analyze("water, salt")
        let upf = IngredientAnalyzer.analyze("water, salt", novaGroup: 4)
        #expect(upf.score < plain.score)
        #expect(upf.shopperChecks[1].status != .yes) // Is it good for you?
    }

    @Test("Ultra-processed products never read as a clean verdict")
    func upfIsAtLeastCaution() {
        let analysis = IngredientAnalyzer.analyze("water, salt", novaGroup: 4)
        #expect(analysis.verdict != .clean)
    }
}
