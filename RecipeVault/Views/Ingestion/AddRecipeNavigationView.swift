import SwiftUI
import SwiftData

/// Wraps the recipe form in a NavigationStack for the "Add Recipe" tab/sidebar section.
///
/// After saving, navigates to the new recipe's detail view.
struct AddRecipeNavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @State private var showingForm = false
    @State private var formID = UUID()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ContentUnavailableView {
                Label("Add Recipe", systemImage: "plus.circle")
            } description: {
                Text("Create a new recipe by entering the title, ingredients, and instructions.")
            } actions: {
                Button("New Recipe") {
                    formID = UUID()
                    showingForm = true
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Add Recipe")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .sheet(isPresented: $showingForm) {
                NavigationStack {
                    RecipeFormView { recipe in
                        modelContext.insert(recipe)
                        navigationPath.append(recipe)
                    }
                }
                .id(formID)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddRecipeNavigationView()
        .modelContainer(for: [Recipe.self, Book.self, Ingredient.self], inMemory: true)
}
