import SwiftUI

/// Placeholder for the ingredient-matching feature (not yet implemented).
struct WhatCanIMakeComingSoonView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("What Can I Make?", systemImage: "magnifyingglass")
            } description: {
                Text("Enter the ingredients you have on hand, and RecipeVault will find recipes you can make.\n\nThis feature is coming soon.")
            }
            .navigationTitle("What Can I Make?")
        }
    }
}

#Preview {
    WhatCanIMakeComingSoonView()
}
