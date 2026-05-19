//
//  AboutView.swift
//  PureRoot
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    mission
                    gradeGuide
                    chemicalsScanned
                    settingsLink
                }
                .padding()
            }
            .navigationTitle("About")
        }
    }

    private var hero: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
            Text("PureRoot")
                .font(.largeTitle.bold())
            Text("Know what's in your food. Find clean sources.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var mission: some View {
        sectionCard(title: "Our mission") {
            Text("Americans deserve to know exactly what's in the food they're feeding their families. PureRoot makes that information instant, honest, and actionable — and connects you directly with small farms, butchers, food hubs, and clean shippers so eating real food is easier than eating processed food.")
                .font(.footnote)
        }
    }

    private var gradeGuide: some View {
        sectionCard(title: "How grades work") {
            VStack(alignment: .leading, spacing: 8) {
                gradeRow("A", "90+", "Mostly clean ingredients", .green)
                gradeRow("B", "80–89", "A few concerns to be aware of", .mint)
                gradeRow("C", "70–79", "Mixed bag — several to watch", .yellow)
                gradeRow("D", "60–69", "Concerning — many problems", .orange)
                gradeRow("F", "Below 60", "Avoid — multiple harmful ingredients", .red)
            }
        }
    }

    private func gradeRow(_ grade: String, _ range: String, _ desc: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            Text(grade)
                .font(.headline.bold())
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(range).font(.caption.weight(.semibold))
                Text(desc).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var chemicalsScanned: some View {
        sectionCard(title: "What we scan for") {
            VStack(alignment: .leading, spacing: 6) {
                bulletRow("Artificial dyes (Red 40, Yellow 5/6, Blue 1, etc.)")
                bulletRow("Synthetic preservatives (BHA, BHT, TBHQ, sodium benzoate)")
                bulletRow("Trans fats and partially hydrogenated oils")
                bulletRow("High-fructose corn syrup and artificial sweeteners")
                bulletRow("Sodium nitrite, nitrates, and nitrosamine precursors")
                bulletRow("MSG, carrageenan, and inflammatory emulsifiers")
                bulletRow("Industrial seed oils (soybean, canola, corn)")
                bulletRow("Vague 'natural flavors' and undisclosed additives")
                bulletRow("Titanium dioxide, caramel coloring class III/IV")
                bulletRow("IARC-listed carcinogens (Groups 1, 2A, 2B)")
            }
        }
    }

    private var settingsLink: some View {
        NavigationLink {
            SettingsView()
        } label: {
            HStack {
                Image(systemName: "gearshape.fill")
                Text("Settings").fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color.prCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(Color.prDivider, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Color.green).frame(width: 5, height: 5).padding(.top, 6)
            Text(text).font(.footnote)
            Spacer()
        }
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.prCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.prDivider, lineWidth: 0.5)
        )
    }
}
