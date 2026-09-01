//
//  ContentView.swift
//  PureRoot
//
//  Created by Tod Vedock on 5/14/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            IngredientScannerView()
                .tabItem { Label("Scan", systemImage: "magnifyingglass") }

            LocalFoodFinderView()
                .tabItem { Label("Local", systemImage: "location") }

            NationwideShippersView()
                .tabItem { Label("Ships", systemImage: "shippingbox") }

            FarmDirectoryView()
                .tabItem { Label("Farms", systemImage: "leaf") }

            AboutView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
        .environment(DirectoryStore())
}
