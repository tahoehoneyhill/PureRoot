//
//  SettingsView.swift
//  PureRoot
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var savedKey: String? = nil
    @State private var selectedModel: AnthropicModel = .haiku
    @State private var showCopied = false

    private let modelKey = "pureroot.anthropic.model"

    var body: some View {
        Form {
            Section {
                SecureField("sk-ant-...", text: $apiKey)
                    .textContentType(.password)
                    #if os(iOS)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    #endif
                HStack {
                    Button("Save key") { saveKey() }
                        .disabled(apiKey.isEmpty)
                    Spacer()
                    if savedKey != nil {
                        Button("Remove", role: .destructive) { removeKey() }
                    }
                }
                if let savedKey {
                    Text("Saved: \(maskedKey(savedKey))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Anthropic API Key")
            } footer: {
                Text("Stored in Keychain on this device. Get a key at console.anthropic.com. The key powers AI ingredient lookup and local food search.")
            }

            Section {
                Picker("Default model", selection: $selectedModel) {
                    ForEach(AnthropicModel.allCases, id: \.self) { model in
                        Text(model.displayName).tag(model)
                    }
                }
                .onChange(of: selectedModel) { _, newValue in
                    UserDefaults.standard.set(newValue.rawValue, forKey: modelKey)
                }
            } header: {
                Text("Model")
            } footer: {
                Text("Haiku is fastest and cheapest (~$0.001 per scan). Sonnet is best for web-search features. Opus is overkill for most use cases.")
            }

            Section {
                Link("Anthropic Console", destination: URL(string: "https://console.anthropic.com")!)
                Link("Anthropic Pricing", destination: URL(string: "https://www.anthropic.com/pricing")!)
            } header: {
                Text("Resources")
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        savedKey = KeychainStore.read(for: APIKeys.anthropic)
        if let stored = UserDefaults.standard.string(forKey: modelKey),
           let model = AnthropicModel(rawValue: stored) {
            selectedModel = model
        }
    }

    private func saveKey() {
        KeychainStore.save(apiKey, for: APIKeys.anthropic)
        savedKey = apiKey
        apiKey = ""
    }

    private func removeKey() {
        KeychainStore.delete(for: APIKeys.anthropic)
        savedKey = nil
    }

    private func maskedKey(_ key: String) -> String {
        let suffix = key.suffix(4)
        return "•••• \(suffix)"
    }
}
