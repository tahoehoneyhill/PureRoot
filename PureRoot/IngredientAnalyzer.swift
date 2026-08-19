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

struct ContaminantExposure: Identifiable {
    let id = UUID()
    let title: String
    let triggeredBy: String
    let detail: String
    let risk: IngredientRisk
    let carcinogen: CarcinogenClass
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
    let contaminantExposures: [ContaminantExposure]

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
    var hasContaminantExposures: Bool { !contaminantExposures.isEmpty }

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

    private struct ContaminantRule {
        let triggerPatterns: [String]
        let organicExempt: Bool
        let title: String
        let detail: String
        let risk: IngredientRisk
        let carcinogen: CarcinogenClass
    }

    private static let contaminantRules: [ContaminantRule] = [
        ContaminantRule(
            triggerPatterns: ["wheat", "oats", "oat flour", "rolled oats", "barley", "rye", "spelt"],
            organicExempt: true,
            title: "Glyphosate residue likely",
            detail: "Conventional wheat, oats, barley, and rye are routinely sprayed with glyphosate (Roundup) as a pre-harvest drying agent. USDA and independent testing detects glyphosate residue in the majority of conventional grain products.",
            risk: .caution,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["corn", "cornstarch", "corn starch", "corn flour", "cornmeal", "corn meal", "corn syrup", "corn oil"],
            organicExempt: true,
            title: "Atrazine & glyphosate residue likely",
            detail: "Conventional US corn is the single largest use of atrazine (an EU-banned endocrine disruptor) and glyphosate. Residues are routinely detected in corn-derived ingredients.",
            risk: .caution,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["soy", "soybean", "soya", "soy protein", "soy flour"],
            organicExempt: true,
            title: "Glyphosate & 2,4-D residue likely",
            detail: "Over 90% of US soybeans are genetically modified for glyphosate tolerance (Roundup Ready) and increasingly 2,4-D. Residues are common in conventional soy-derived ingredients.",
            risk: .caution,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["canola", "rapeseed"],
            organicExempt: true,
            title: "Glyphosate residue likely",
            detail: "Conventional canola is genetically modified for glyphosate tolerance and is also typically chemically extracted with hexane.",
            risk: .caution,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["beet sugar", "sugar beet"],
            organicExempt: true,
            title: "Glyphosate residue possible (sugar beet)",
            detail: "Roughly half of US sugar comes from genetically modified sugar beets sprayed with glyphosate.",
            risk: .caution,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["cottonseed", "cotton seed"],
            organicExempt: true,
            title: "Glyphosate & dicamba residue likely",
            detail: "Conventional cotton is GMO for glyphosate and dicamba tolerance, and is regulated as a non-food crop — meaning pesticide tolerances are higher than for food crops.",
            risk: .avoid,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["microwave popcorn", "popcorn bag"],
            organicExempt: false,
            title: "PFAS exposure likely (packaging)",
            detail: "Microwave popcorn bags are commonly lined with PFAS forever chemicals to resist grease. PFAS migrates into the food during heating.",
            risk: .avoid,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["non-stick", "nonstick", "teflon", "fluoropolymer", "fluorinated"],
            organicExempt: false,
            title: "PFAS / PTFE exposure",
            detail: "Non-stick and fluoropolymer surfaces are part of the PFAS family. They shed microparticles into food and release toxic fumes when overheated.",
            risk: .avoid,
            carcinogen: .probable
        ),
        ContaminantRule(
            triggerPatterns: ["grease-resistant", "grease resistant", "wax-coated", "wax coated"],
            organicExempt: false,
            title: "PFAS-coated packaging possible",
            detail: "Grease-resistant wrappers, fast-food containers, and bakery liners frequently contain PFAS coatings that migrate into food.",
            risk: .avoid,
            carcinogen: .probable
        ),
    ]

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

        // MARK: Forever chemicals (PFAS)
        IngredientEntry(canonicalName: "PFOA", aliases: ["perfluorooctanoic acid", "perfluorooctanoate", "c8"], risk: .avoid,
                        concern: "Forever chemical that bioaccumulates and never breaks down. IARC reclassified PFOA as a Group 1 known human carcinogen in 2024. Linked to kidney and testicular cancer, thyroid disease, and immune suppression.",
                        purpose: "Historically used to make non-stick coatings, grease-resistant food wrappers, and stain-proof packaging.",
                        alternative: "Glass, stainless steel, or uncoated paper packaging.",
                        carcinogen: .known),
        IngredientEntry(canonicalName: "PFOS", aliases: ["perfluorooctane sulfonate", "perfluorooctanesulfonic acid"], risk: .avoid,
                        concern: "Forever chemical classified by IARC as a possible human carcinogen (Group 2B). Persists in the body and the environment for decades.",
                        purpose: "Used in stain repellents, food packaging coatings, and firefighting foam.",
                        alternative: "PFAS-free packaging and cookware.",
                        carcinogen: .possible),
        IngredientEntry(canonicalName: "PFAS", aliases: ["perfluoroalkyl", "polyfluoroalkyl", "per- and polyfluoroalkyl", "forever chemical", "forever chemicals"], risk: .avoid,
                        concern: "Umbrella term for thousands of synthetic 'forever chemicals' that do not break down in the body or environment. Linked to cancer, immune dysfunction, hormone disruption, and developmental harm.",
                        purpose: "Grease- and water-resistant coatings on fast-food wrappers, microwave popcorn bags, takeout containers, and pizza boxes.",
                        alternative: "Unwrapped or paper-wrapped foods from sources that explicitly state PFAS-free packaging.",
                        carcinogen: .probable),
        IngredientEntry(canonicalName: "PTFE", aliases: ["polytetrafluoroethylene", "teflon", "fluoropolymer", "fluoropolymers"], risk: .avoid,
                        concern: "Synthetic fluoropolymer in the PFAS family. Can shed microparticles into food and releases toxic fumes when overheated. Manufactured using other PFAS.",
                        purpose: "Non-stick cookware coatings and processing equipment surfaces.",
                        alternative: "Cast iron, stainless steel, carbon steel, or ceramic-coated cookware."),
        IngredientEntry(canonicalName: "GenX", aliases: ["hfpo-da", "hexafluoropropylene oxide dimer acid"], risk: .avoid,
                        concern: "Replacement chemical for PFOA that has been shown in EPA studies to cause similar liver, kidney, and immune-system damage. Still a forever chemical.",
                        purpose: "Newer generation PFAS used in food contact materials.",
                        alternative: "Avoid products with fluorinated or 'non-stick' food contact materials."),

        // MARK: Pesticide & herbicide residues
        IngredientEntry(canonicalName: "Glyphosate", aliases: ["roundup", "glyphosate residue"], risk: .avoid,
                        concern: "World's most widely used herbicide. Classified by IARC as a Group 2A probable human carcinogen. Routinely detected as a residue on conventional wheat, oats, soy, and corn products. Endocrine disruptor and gut-microbiome disruptor.",
                        purpose: "Broad-spectrum weed killer and pre-harvest desiccant on grains.",
                        alternative: "Certified organic or 'Glyphosate Residue Free' verified products.",
                        carcinogen: .probable),
        IngredientEntry(canonicalName: "Atrazine", aliases: [], risk: .avoid,
                        concern: "Endocrine disruptor banned in the European Union since 2004. Linked to birth defects, hormone disruption, and reproductive harm. Heavily applied to US corn — frequent groundwater contaminant.",
                        purpose: "Herbicide used on conventional corn, sorghum, and sugarcane.",
                        alternative: "Certified organic corn and grain products."),
        IngredientEntry(canonicalName: "2,4-D", aliases: ["2,4-dichlorophenoxyacetic acid", "2 4-d"], risk: .avoid,
                        concern: "IARC Group 2B (possibly carcinogenic to humans). A component of Agent Orange. Linked to non-Hodgkin lymphoma in agricultural worker studies.",
                        purpose: "Broadleaf herbicide used on conventional grains, lawns, and pastures.",
                        alternative: "Certified organic grain and meat products.",
                        carcinogen: .possible),
        IngredientEntry(canonicalName: "Dicamba", aliases: [], risk: .avoid,
                        concern: "Volatile herbicide notorious for drift damage to neighboring farms. Suspected endocrine and developmental toxicant.",
                        purpose: "Broadleaf herbicide paired with genetically modified soy and cotton.",
                        alternative: "Certified organic or non-GMO verified products."),
        IngredientEntry(canonicalName: "Chlorpyrifos", aliases: [], risk: .avoid,
                        concern: "Organophosphate insecticide linked to lower IQ, ADHD, and developmental delays in children. Banned for food use in the US in 2021, but residues persist on imported produce.",
                        purpose: "Insecticide on conventional fruits, vegetables, and nuts.",
                        alternative: "Certified organic produce, especially for children's foods."),
        IngredientEntry(canonicalName: "Paraquat", aliases: ["paraquat dichloride"], risk: .avoid,
                        concern: "One of the most acutely toxic herbicides in use. Strong epidemiological link to Parkinson's disease. Banned in the EU and over 30 other countries; still used in the US.",
                        purpose: "Herbicide on conventional soy, corn, cotton, and orchard crops.",
                        alternative: "Certified organic products."),
        IngredientEntry(canonicalName: "Malathion", aliases: [], risk: .avoid,
                        concern: "IARC Group 2A probable human carcinogen. Organophosphate that interferes with the nervous system.",
                        purpose: "Insecticide on conventional grain, fruit, and vegetable crops.",
                        alternative: "Certified organic produce and grains.",
                        carcinogen: .probable),
        IngredientEntry(canonicalName: "Neonicotinoids", aliases: ["neonicotinoid", "imidacloprid", "clothianidin", "thiamethoxam"], risk: .avoid,
                        concern: "Systemic insecticides absorbed into the entire plant — cannot be washed off. Drivers of pollinator collapse. Detected in conventional baby foods and produce.",
                        purpose: "Seed treatments and sprays on conventional fruits, vegetables, and grains.",
                        alternative: "Certified organic produce."),
        IngredientEntry(canonicalName: "DDT", aliases: ["dichlorodiphenyltrichloroethane", "ddt residue"], risk: .avoid,
                        concern: "IARC Group 2A probable human carcinogen. Banned for US agricultural use in 1972 but still detected in fatty fish, dairy, and meat due to bioaccumulation in soil and water.",
                        purpose: "Legacy organochlorine insecticide.",
                        alternative: "Lower-fat or plant-based protein sources from clean watersheds.",
                        carcinogen: .probable),

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

        let exposures = inferContaminantExposures(from: lowered)

        var score = 100
        for ing in ingredients {
            if let entry = ing.entry {
                score += entry.risk.scoreDelta
            } else {
                score -= 1
            }
        }
        score -= min(exposures.count * 2, 8)
        score = max(0, min(100, score))

        let grade: String
        switch score {
        case 90...100: grade = "A"
        case 80..<90: grade = "B"
        case 70..<80: grade = "C"
        case 60..<70: grade = "D"
        default: grade = "F"
        }

        return IngredientAnalysis(score: score, grade: grade, ingredients: ingredients, contaminantExposures: exposures)
    }

    private static func inferContaminantExposures(from fragments: [(String, String)]) -> [ContaminantExposure] {
        var exposures: [ContaminantExposure] = []
        var seenTitles = Set<String>()

        for rule in contaminantRules {
            for (raw, low) in fragments {
                guard rule.triggerPatterns.contains(where: { low.contains($0) }) else { continue }
                if rule.organicExempt && low.contains("organic") { continue }
                if seenTitles.contains(rule.title) { continue }
                seenTitles.insert(rule.title)
                exposures.append(ContaminantExposure(
                    title: rule.title,
                    triggeredBy: raw,
                    detail: rule.detail,
                    risk: rule.risk,
                    carcinogen: rule.carcinogen
                ))
                break
            }
        }

        return exposures
    }
}
