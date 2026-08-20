# Changelog

## 6.2

**Added**
- **Heavy-metal & carcinogen detection.** Ingredient scans now infer likely
  cancer-causing contaminants by food type: inorganic arsenic (rice, rice
  syrup, infant rice cereal), lead & cadmium (cocoa, dark chocolate), lead
  (cinnamon and ground spices), methylmercury (tuna, swordfish, shark and
  other predatory fish), arsenic & lead (apple/grape juice), mixed heavy
  metals (protein powders), and acrylamide (fried/roasted starches, coffee).
- **Per-claim citations** for every new warning — FDA Arsenic in Food, FDA
  Lead in Food, FDA "Closer to Zero," FDA/EPA Advice About Eating Fish, and
  FDA Acrylamide — added to `Citations` and the in-app Sources list.
- **Safer-alternative recommendations.** When a product scores poorly or any
  carcinogen is detected, the report suggests a hand-vetted clean brand from
  the app's shipper directory and offers a "Browse clean [category] options"
  button that opens the directory pre-filtered to the matched category.

**Changed**
- About tab "What we scan for" list now includes heavy metals and acrylamide.
- `NationwideShippersView` accepts an initial category and an optional
  "Done" action so it can be presented filtered from the scanner.

### App Store "What's New" text
- Ingredient scans now flag heavy metals and other cancer-causing
  contaminants — arsenic in rice, lead and cadmium in cocoa and dark
  chocolate, mercury in large fish, lead in cinnamon and spices, and
  acrylamide in fried and roasted foods.
- Every warning links to its source (FDA, IARC, EPA, CDC).
- When a product scores poorly, PureRootFood now suggests a cleaner,
  hand-vetted alternative you can buy instead.
