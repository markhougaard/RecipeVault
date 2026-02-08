import SwiftUI

/// Placeholder for recipe ingestion features (not yet implemented).
struct AddRecipeComingSoonView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Add Recipe", systemImage: "plus.circle")
            } description: {
                Text("Add recipes by scanning cookbook pages, pasting a URL, or typing them in manually.\n\nThis feature is coming soon.")
            }
            .navigationTitle("Add Recipe")
        }
    }
}

#Preview {
    AddRecipeComingSoonView()
}
