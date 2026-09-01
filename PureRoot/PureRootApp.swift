//
//  PureRootApp.swift
//  PureRoot
//
//  Created by Tod Vedock on 5/14/26.
//

import SwiftUI

@main
struct PureRootApp: App {
    @State private var directory = DirectoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(directory)
                .task { await directory.refresh() }
        }
    }
}

/// Single source of truth for the app's external links.
/// These are live GitHub Pages URLs specific to PureRootFood; keep them in sync
/// with the Support URL and Privacy Policy fields in App Store Connect.
enum AppLinks {
    static let support = URL(string: "https://tahoehoneyhill.github.io/purerootfood/support")!
    static let privacy = URL(string: "https://tahoehoneyhill.github.io/purerootfood/privacy")!
    static let terms = URL(string: "https://tahoehoneyhill.github.io/purerootfood/terms")!
}
