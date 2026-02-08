import SwiftUI
import SwiftData

/// Displays the full recipe collection with search and cuisine filtering.
struct RecipeListView: View {
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @State private var searchText = ""
    @State private var selectedCuisine: String?

    var body: some View {
        NavigationStack {
            List(filteredRecipes) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes...")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    cuisineFilterMenu
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .overlay {
                if recipes.isEmpty {
                    ContentUnavailableView("No Recipes", systemImage: "fork.knife",
                                           description: Text("Add your first recipe to get started."))
                } else if filteredRecipes.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }

    // MARK: - Filtering

    private var filteredRecipes: [Recipe] {
        var result = recipes

        if let selectedCuisine {
            result = result.filter { $0.recipeCuisine == selectedCuisine }
        }

        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            result = result.filter { recipe in
                recipe.name.localizedStandardContains(query) ||
                recipe.keywords.contains { $0.localizedStandardContains(query) } ||
                recipe.normalizedIngredients.contains { $0.localizedStandardContains(query) }
            }
        }

        return result
    }

    // MARK: - Cuisine Filter

    private var availableCuisines: [String] {
        Array(Set(recipes.compactMap(\.recipeCuisine))).sorted()
    }

    private var cuisineFilterMenu: some View {
        Menu {
            Button("All Cuisines") { selectedCuisine = nil }
            Divider()
            ForEach(availableCuisines, id: \.self) { cuisine in
                Button {
                    selectedCuisine = cuisine
                } label: {
                    if selectedCuisine == cuisine {
                        Label(cuisine, systemImage: "checkmark")
                    } else {
                        Text(cuisine)
                    }
                }
            }
        } label: {
            Label("Filter", systemImage: selectedCuisine != nil
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
    }
}

// MARK: - Preview

#Preview {
    RecipeListView()
        .modelContainer(for: [Recipe.self, Book.self, Ingredient.self], inMemory: true)
}
