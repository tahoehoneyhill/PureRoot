//
//  PureRootApp.swift
//  PureRoot
//
//  Created by Tod Vedock on 5/14/26.
//

import SwiftUI
import SwiftData

@main
struct PureRootApp: App {
    @State private var subscriptions = SubscriptionManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootGate()
                .environment(subscriptions)
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct RootGate: View {
    @Environment(SubscriptionManager.self) private var subscriptions

    var body: some View {
        #if DEBUG
        ContentView()
        #else
        if subscriptions.isSubscribed {
            ContentView()
        } else {
            PaywallView()
        }
        #endif
    }
}
