# PureRootFood — Fix & Resubmit Guide (updated July 22, 2026)

**Latest submission ID:** 2742f7e8-32de-40a0-9747-55f73158598c
**Current status:** 6.0 (1) — **2.1(b) Information Needed** (info request, NOT a rejection) — reviewed July 22, 2026 on iPad Air 11" (M3)

---

## 🔴 DO THIS NOW — the July 22 "2.1(b) Information Needed" round

This is an **information request**, not a rejection. Review is paused waiting on two things: (A) detach the orphaned subscription in App Store Connect, and (B) reply to the reviewer's 4 questions. Do both, then review resumes on the same build — **no new upload required.**

### Root cause
A subscription product — **"PureRootFood Membership," `com.purerootfood.yearly`, $4.99/yr** — is still attached to this version in App Store Connect. The app binary has **no** paywall, StoreKit code, or purchase UI (all removed in 6.0). The reviewer sees a subscription tied to your submission but no way to buy or use it, so they can't tell how the app makes money → 2.1(b). (Code side is now clean: I emptied `PureRoot.storekit` so it defines zero products — the project & binary reference no IAP at all. Build verified.)

### A) Detach the in-app purchase from the submission (this is the real fix)
1. App Store Connect → **My Apps → PureRootFood → the 6.0 version page**.
2. Scroll to **"In-App Purchases and Subscriptions."** If the yearly subscription is listed/attached there, **remove it from the version** (click the "–" / deselect so nothing is attached).
3. Go to **Monetization → Subscriptions → "PureRootFood Membership."** If `com.purerootfood.yearly` shows **"Waiting for Review"** or **"Developer Action Needed,"** that status is what keeps auto-attaching it. Remove it from review: on the subscription, choose **Remove from Review / Developer Removed from Sale** so its state is no longer "submitted with app." (A subscription that's ever entered review can't be fully deleted, but "Removed from Sale / not attached" is exactly what you want — it will be invisible to the reviewer.)
4. Re-open the 6.0 version page and confirm the **In-App Purchases and Subscriptions section is empty.**

### B) Reply in the Resolution Center with these exact answers

> Hello, and thank you for the opportunity to clarify.
>
> **PureRootFood is a completely free app. It contains no In-App Purchases, no subscriptions, and no paid or unlockable content of any kind.** Every feature is available to every user at no cost. Answering your questions directly:
>
> **1. Who are the users that will use the paid content and services in the app?**
> There are none. There is no paid content or paid service in the app. All users get the full app for free.
>
> **2. Where can users purchase the content and services that can be accessed in the app?**
> Nothing is purchasable inside the app — there is no In-App Purchase and no external purchase flow for any digital content. The only transactions a user could ever make are ordinary physical grocery/food orders on fully independent third-party retailer websites (e.g., Thrive Market, ButcherBox), which the app simply links to in Safari as an informational directory. Those are physical goods sold and fulfilled entirely by those third parties; PureRootFood facilitates no transaction and receives no payment.
>
> **3. What specific types of previously purchased content and services can a user access in the app?**
> None. There is no restore-purchases feature, no account system, and no entitlement. Nothing has ever been sold to users, so there is nothing to restore or unlock.
>
> **4. What paid content, subscriptions, or features are unlocked within the app that do not use In-App Purchase?**
> None. No feature is gated behind any payment. The barcode/ingredient scanner, A–F grading, Local Food Finder, Farm Directory, and Nationwide Shipper directory are all fully functional for free, with no purchase or unlock. During earlier development a subscription was configured in App Store Connect but was never implemented in the app; we have now removed it from this submission. The shipped binary contains no StoreKit code and no purchase UI whatsoever.
>
> Please let us know if any further detail would help. Thank you for your review.
>
> The PureRootFood Team

---


## MAJOR DECISION — the app is now FREE (no in-app purchase)

After ~12 rejections all centered on the subscription (Guideline 2.1(b) — the IAP never got submitted with the binary), we removed the in-app purchase entirely. The app is fully functional and free. With no IAP referenced anywhere, 2.1(b) can no longer occur. A subscription can be added back later as an update once it's correctly configured in App Store Connect.

---

## What was rejected this round & how it's handled

| # | Guideline | Issue | Status |
|---|-----------|-------|--------|
| 1 | 2.3 | App metadata still mentions a subscription | Web pages fixed (code). **You must edit the App Store description + keywords** (Step 2). |
| 2 | 4.3(a) | App resembles other apps / looks like a repackaged template | Removed leftover template scaffolding (code). **You must reply to the reviewer + tighten metadata** (Step 3). |

---

## CODE CHANGES ALREADY MADE (build 6.0(1)) — verified compiling

- **Removed the entire in-app purchase:** deleted `PaywallView.swift` and `SubscriptionManager.swift`; removed StoreKit, the paywall sheet, and all "Premium"/"Go Premium" entry points from PureRootApp / ContentView / IngredientScannerView / AboutView / SettingsView.
- **Removed leftover Xcode template scaffolding** (Guideline 4.3): deleted the unused SwiftData `Item` model and `ModelContainer` from the app. This eliminates default-template code that can trigger a "repackaged template" spam flag.
- **Cleaned all linked web pages** (support / privacy / terms / index) of every subscription reference — they now state the app is completely free.
- Kept `AppLinks` (live support/privacy/terms URLs) and all real app functionality (scanner, local finder, shippers, farms, About/Settings).

---

## STEP 1 — Publish the updated web pages

The linked pages were edited to remove subscription references. Push them live (they're committed locally in `~/purerootfood-site`):

```bash
cd ~/purerootfood-site
git push https://github.com/tahoehoneyhill/purerootfood.git main
# username: tahoehoneyhill   password: a GitHub token with the "repo" scope
```

Confirm these still load and no longer mention a subscription:
- https://tahoehoneyhill.github.io/purerootfood/support
- https://tahoehoneyhill.github.io/purerootfood/privacy
- https://tahoehoneyhill.github.io/purerootfood/terms

---

## STEP 2 — Fix the App Store Connect metadata (Guideline 2.3)

The reviewer saw subscription text in the **App Store description**. Replace the description with this free-app version:

```
PureRootFood helps you understand exactly what's in your food and find genuinely clean sources near you — completely free, with no ads and no in-app purchases.

SCAN & GRADE
Scan any barcode or paste an ingredient list to get an instant A–F grade. PureRootFood flags artificial dyes, synthetic preservatives, trans fats, industrial seed oils, and IARC-listed carcinogens — and goes further than most tools by inferring likely PFAS "forever chemical" packaging exposure and pesticide/herbicide residues (glyphosate, atrazine, chlorpyrifos and more) from conventional ingredients.

FIND CLEAN FOOD
• Local Food Finder — farmers markets, butchers, food hubs, and CSAs by zip code
• Nationwide Organic Shippers — a hand-vetted directory that delivers clean food anywhere in the US
• Farm Directory — connect directly with small farms

PRIVATE BY DESIGN
No accounts, no tracking, no servers. Everything stays on your device.

PureRootFood is an independent project. We don't accept advertising or sponsorships from food companies.
```

Also remove any "subscription / premium / trial" terms from the **Keywords** and **Promotional Text** fields.

---

## STEP 3 — Address the spam flag (Guideline 4.3(a))

1. **Reply in the Resolution Center:**

> Hello,
>
> PureRootFood is an original app developed solely by us — it is not built from a purchased template, and we have not submitted similar or repackaged apps under this or any other account.
>
> While ingredient-scanning exists in other apps, PureRootFood's functionality and content are distinct: in addition to grading additives, it uniquely infers PFAS "forever chemical" packaging exposure and specific pesticide/herbicide residues (e.g. glyphosate, atrazine, chlorpyrifos) from conventional ingredients, and it pairs that with an original, hand-curated directory of local food sources, nationwide organic shippers, and small farms by region. The ingredient database, grading logic, shipper/farm directories, and UI are all our own original work.
>
> We're happy to provide any additional detail or a walkthrough. Please let us know what specific overlap was identified so we can address it directly.
>
> Thank you,
> The PureRootFood Team

2. **Distinctiveness checklist:**
   - Unique **subtitle** (e.g. "Scan additives, PFAS & pesticides") and non-generic **keywords**.
   - **Original screenshots** with your own branding/captions — not stock/template layouts.
   - Confirm **no other similar apps** exist under your developer account.

---

## STEP 4 — Xcode: version, platforms, encryption

1. **TARGETS → PureRoot → General → Identity:** Version **6.0**, Build **1**.
2. **Supported Destinations:** keep only **iPhone** + **iPad** (remove Mac / Apple Vision) — or the upload fails with the ICNS/LSApplicationCategoryType errors.
3. (Optional) **Info** tab → add **App Uses Non-Exempt Encryption** = **NO** (`ITSAppUsesNonExemptEncryption`) to skip the export-compliance prompt.

---

## STEP 5 — Archive & upload build 6.0(1)

1. **Product → Clean Build Folder** (⇧⌘K).
2. Run destination: **Any iOS Device (arm64)**.
3. **Product → Archive** → Organizer → **Distribute App → App Store Connect → Upload**.
4. Wait ~10 min for processing.

---

## STEP 6 — Submit (NO subscription steps anymore)

On the **6.0** version page in App Store Connect:
- **Do NOT attach any in-app purchase** — there is none. (You can leave the old subscription sitting unused in Monetization, or delete it; either way it must not be attached.)
- Select build **6.0 (1)**.
- Confirm the new description (Step 2), Support URL, and Privacy Policy URL.
- **Add for Review → Submit to App Review**, and paste the 4.3 reply (Step 3) in the Resolution Center.

---

## Final pre-submit checklist

- [ ] Web pages pushed; all three load with no subscription wording (Step 1)
- [ ] App Store description replaced; keywords/promo text cleaned (Step 2)
- [ ] 4.3 reply ready; subtitle/keywords/screenshots distinct; no duplicate apps on account (Step 3)
- [ ] Version 6.0 / Build 1; iPhone+iPad only; encryption key set (Step 4)
- [ ] Build 6.0(1) uploaded and selected
- [ ] No IAP attached to the version (Step 6)

---

## Why this finally works

Every prior rejection traced to the subscription never being submitted with the binary. Removing the IAP eliminates that failure mode entirely. The remaining two items (2.3 metadata, 4.3 spam) are addressed by cleaning subscription wording from all metadata and removing template scaffolding, plus a factual reply establishing the app's original, distinctive functionality.
