//
//  SettingsView.swift
//  PureRoot
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }

    private var buildNumber: String {
        (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    }

    var body: some View {
        Form {
            Section("App") {
                LabeledContent("Version", value: "\(appVersion) (\(buildNumber))")
                Link("PureRoot website", destination: URL(string: "https://pureroot.app")!)
                Link("Privacy Policy", destination: URL(string: "https://pureroot.app/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://pureroot.app/terms")!)
            }

            Section("Subscription") {
                Link("Manage subscription",
                     destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                Link("Restore purchases",
                     destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
            }

            Section("Credits") {
                Link("Open Food Facts (barcode database)",
                     destination: URL(string: "https://world.openfoodfacts.org/")!)
                Link("IARC monograph data",
                     destination: URL(string: "https://monographs.iarc.who.int/")!)
            }

            Section {
                Text("PureRoot is an independent project. We don't accept advertising or sponsorships from food companies.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
