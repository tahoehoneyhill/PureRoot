//
//  Citations.swift
//  PureRoot
//

import Foundation

/// Authoritative sources cited in the ingredient analysis report.
/// Required by App Store Guideline 1.4.1 — health information must
/// include easy-to-find citations to its sources.
enum Citations {
    struct Source: Identifiable {
        let id: String
        let name: String
        let detail: String
        let url: URL
    }

    static let all: [Source] = [
        Source(id: "iarc",
               name: "IARC Monographs — WHO",
               detail: "Carcinogen classifications (Groups 1, 2A, 2B)",
               url: URL(string: "https://monographs.iarc.who.int/list-of-classifications")!),
        Source(id: "fda",
               name: "FDA — Substances Added to Food",
               detail: "US food additive safety and approval status",
               url: URL(string: "https://www.fda.gov/food/food-additives-petitions/substances-added-food")!),
        Source(id: "usda-pdp",
               name: "USDA Pesticide Data Program",
               detail: "Annual pesticide residue testing of US foods",
               url: URL(string: "https://www.ams.usda.gov/datasets/pdp")!),
        Source(id: "epa-glyphosate",
               name: "EPA — Glyphosate",
               detail: "US pesticide registration and residue tolerances",
               url: URL(string: "https://www.epa.gov/ingredients-used-pesticide-products/glyphosate")!),
        Source(id: "atsdr-pfas",
               name: "CDC / ATSDR — PFAS",
               detail: "Health effects of PFAS \"forever chemicals\"",
               url: URL(string: "https://www.atsdr.cdc.gov/pfas/index.html")!),
        Source(id: "fda-czr",
               name: "FDA — Closer to Zero",
               detail: "Reducing lead, arsenic, cadmium & mercury in food",
               url: URL(string: "https://www.fda.gov/food/environmental-contaminants-food/closer-zero-reducing-childhood-exposure-contaminants-foods")!),
        Source(id: "efsa",
               name: "EFSA — Food Additives",
               detail: "European food additive re-evaluations",
               url: URL(string: "https://www.efsa.europa.eu/en/topics/topic/food-additives")!),
        Source(id: "pubchem",
               name: "NIH PubChem",
               detail: "Chemical properties and toxicity data",
               url: URL(string: "https://pubchem.ncbi.nlm.nih.gov")!),
        Source(id: "nova",
               name: "NOVA — Open Food Facts",
               detail: "Ultra-processed food (NOVA group) classification",
               url: URL(string: "https://world.openfoodfacts.org/nova")!),
        Source(id: "nutriscore",
               name: "Nutri-Score — Open Food Facts",
               detail: "Nutritional quality grade (A–E) used for the nutrition score",
               url: URL(string: "https://world.openfoodfacts.org/nutriscore")!),
    ]

    static let iarcURL = all.first { $0.id == "iarc" }!.url
    static let usdaPDPURL = all.first { $0.id == "usda-pdp" }!.url
    static let novaURL = all.first { $0.id == "nova" }!.url
    static let nutriScoreURL = all.first { $0.id == "nutriscore" }!.url

    static let disclaimer = "PureRootFood provides educational information from the public sources above, not medical advice. Consult a healthcare professional for personal health decisions."

    /// Citations for the specific claim made about each ingredient,
    /// pointing at the page of the authority named in the claim text.
    private static let specificSources: [String: (label: String, urlString: String)] = [
        "High Fructose Corn Syrup": ("FDA — High Fructose Corn Syrup Q&A", "https://www.fda.gov/food/food-additives-petitions/high-fructose-corn-syrup-questions-and-answers"),
        "Partially Hydrogenated Oil": ("FDA — Trans Fat", "https://www.fda.gov/food/food-additives-petitions/trans-fat"),
        "Mono and Diglycerides": ("FDA — Trans Fat", "https://www.fda.gov/food/food-additives-petitions/trans-fat"),
        "BHA": ("NTP Report on Carcinogens", "https://ntp.niehs.nih.gov/whatwestudy/assessments/cancer/roc"),
        "BHT": ("NIH PubChem — BHT", "https://pubchem.ncbi.nlm.nih.gov/compound/31404"),
        "TBHQ": ("NIH PubChem — TBHQ", "https://pubchem.ncbi.nlm.nih.gov/compound/16043"),
        "Sodium Nitrite": ("WHO — Processed Meat & Cancer Q&A", "https://www.who.int/news-room/questions-and-answers/item/cancer-carcinogenicity-of-the-consumption-of-red-meat-and-processed-meat"),
        "Red 40": ("California OEHHA — Synthetic Food Dyes Assessment", "https://oehha.ca.gov/risk-assessment/report/health-effects-assessment-potential-neurobehavioral-effects-synthetic-food-dyes"),
        "Yellow 5": ("California OEHHA — Synthetic Food Dyes Assessment", "https://oehha.ca.gov/risk-assessment/report/health-effects-assessment-potential-neurobehavioral-effects-synthetic-food-dyes"),
        "Yellow 6": ("California OEHHA — Synthetic Food Dyes Assessment", "https://oehha.ca.gov/risk-assessment/report/health-effects-assessment-potential-neurobehavioral-effects-synthetic-food-dyes"),
        "Blue 1": ("California OEHHA — Synthetic Food Dyes Assessment", "https://oehha.ca.gov/risk-assessment/report/health-effects-assessment-potential-neurobehavioral-effects-synthetic-food-dyes"),
        "Titanium Dioxide": ("EFSA — Titanium Dioxide (E171) Ruling", "https://www.efsa.europa.eu/en/news/titanium-dioxide-e171-no-longer-considered-safe-when-used-food-additive"),
        "PFOA": ("IARC — PFOA/PFOS Carcinogenicity Evaluation", "https://www.iarc.who.int/news-events/iarc-monographs-evaluate-the-carcinogenicity-of-perfluorooctanoic-acid-pfoa-and-perfluorooctanesulfonic-acid-pfos/"),
        "PFOS": ("IARC — PFOA/PFOS Carcinogenicity Evaluation", "https://www.iarc.who.int/news-events/iarc-monographs-evaluate-the-carcinogenicity-of-perfluorooctanoic-acid-pfoa-and-perfluorooctanesulfonic-acid-pfos/"),
        "PFAS": ("CDC / ATSDR — PFAS Health Effects", "https://www.atsdr.cdc.gov/pfas/index.html"),
        "PTFE": ("CDC / ATSDR — PFAS Health Effects", "https://www.atsdr.cdc.gov/pfas/index.html"),
        "GenX": ("EPA — GenX Toxicity Assessment", "https://www.epa.gov/chemical-research/human-health-toxicity-assessments-genx-chemicals"),
        "Glyphosate": ("IARC — Glyphosate (Group 2A)", "https://www.iarc.who.int/featured-news/media-centre-iarc-news-glyphosate/"),
        "Atrazine": ("EPA — Atrazine", "https://www.epa.gov/ingredients-used-pesticide-products/atrazine"),
        "2,4-D": ("EPA — 2,4-D", "https://www.epa.gov/ingredients-used-pesticide-products/24-d"),
        "Dicamba": ("EPA — Dicamba", "https://www.epa.gov/ingredients-used-pesticide-products/dicamba"),
        "Chlorpyrifos": ("EPA — Chlorpyrifos", "https://www.epa.gov/ingredients-used-pesticide-products/chlorpyrifos"),
        "Paraquat": ("EPA — Paraquat Dichloride", "https://www.epa.gov/ingredients-used-pesticide-products/paraquat-dichloride"),
        "Malathion": ("EPA — Malathion", "https://www.epa.gov/mosquitocontrol/malathion"),
        "Neonicotinoids": ("EPA — Neonicotinoid Review", "https://www.epa.gov/pollinator-protection/schedule-review-neonicotinoid-pesticides"),
        "DDT": ("CDC / ATSDR — DDT ToxFAQs", "https://wwwn.cdc.gov/TSP/substances/ToxSubstance.aspx?toxid=20"),
        "Aspartame": ("WHO — Aspartame Hazard Assessment (2023)", "https://www.who.int/news/item/14-07-2023-aspartame-hazard-and-risk-assessment-results-released"),
        "Sucralose": ("FDA — High-Intensity Sweeteners", "https://www.fda.gov/food/food-additives-petitions/additional-information-about-high-intensity-sweeteners-permitted-use-food-united-states"),
        "Acesulfame Potassium": ("FDA — High-Intensity Sweeteners", "https://www.fda.gov/food/food-additives-petitions/additional-information-about-high-intensity-sweeteners-permitted-use-food-united-states"),
        "MSG": ("FDA — MSG Q&A", "https://www.fda.gov/food/food-additives-petitions/questions-and-answers-monosodium-glutamate-msg"),
        "Sodium Benzoate": ("FDA — Benzene in Beverages Q&A", "https://www.fda.gov/food/chemical-contaminants-food/questions-and-answers-occurrence-benzene-soft-drinks-and-other-beverages"),
        "Caramel Color": ("FDA — 4-MEI Q&A", "https://www.fda.gov/food/food-additives-petitions/questions-answers-about-4-mei"),
    ]

    /// Citation for the specific claim about an ingredient. Prefers the
    /// authority named in the claim text; falls back to IARC for classified
    /// carcinogens, then to the compound's PubChem record.
    static func source(for entry: IngredientEntry) -> (label: String, url: URL) {
        if let specific = specificSources[entry.canonicalName], let url = URL(string: specific.urlString) {
            return (specific.label, url)
        }
        if entry.carcinogen.isAny {
            return ("IARC Monographs (WHO)", iarcURL)
        }
        let query = entry.canonicalName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? entry.canonicalName
        return ("NIH PubChem", URL(string: "https://pubchem.ncbi.nlm.nih.gov/#query=\(query)")!)
    }

    /// Citation for a contaminant-exposure inference, matched to the
    /// chemical named in the exposure title.
    static func source(forExposureTitle title: String) -> (label: String, url: URL) {
        let lowered = title.lowercased()
        if lowered.contains("arsenic") {
            return ("FDA — Arsenic in Food", URL(string: "https://www.fda.gov/food/environmental-contaminants-food/arsenic-food-and-dietary-supplements")!)
        }
        if lowered.contains("cadmium") {
            return ("FDA — Closer to Zero (Heavy Metals)", URL(string: "https://www.fda.gov/food/environmental-contaminants-food/closer-zero-reducing-childhood-exposure-contaminants-foods")!)
        }
        if lowered.contains("lead") {
            return ("FDA — Lead in Food", URL(string: "https://www.fda.gov/food/environmental-contaminants-food/lead-food-and-foodwares")!)
        }
        if lowered.contains("mercury") {
            return ("FDA/EPA — Advice About Eating Fish", URL(string: "https://www.fda.gov/food/consumers/advice-about-eating-fish")!)
        }
        if lowered.contains("acrylamide") {
            return ("FDA — Acrylamide", URL(string: "https://www.fda.gov/food/process-contaminants-food/acrylamide")!)
        }
        if lowered.contains("pfas") || lowered.contains("ptfe") {
            return ("CDC / ATSDR — PFAS Health Effects", URL(string: "https://www.atsdr.cdc.gov/pfas/index.html")!)
        }
        if lowered.contains("atrazine") {
            return ("EPA — Atrazine", URL(string: "https://www.epa.gov/ingredients-used-pesticide-products/atrazine")!)
        }
        if lowered.contains("glyphosate") {
            return ("IARC — Glyphosate (Group 2A)", URL(string: "https://www.iarc.who.int/featured-news/media-centre-iarc-news-glyphosate/")!)
        }
        return ("USDA Pesticide Data Program", usdaPDPURL)
    }
}
