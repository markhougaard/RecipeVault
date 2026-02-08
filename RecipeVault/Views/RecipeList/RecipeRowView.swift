import SwiftUI
import SwiftData

/// A single row in the recipe list showing name, cuisine, and timing.
struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            RecipeImageView(imageData: recipe.imageData)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    if let time = DurationFormatter.formatted(recipe.totalTime) {
                        Label(time, systemImage: "clock")
                    }
                    Label("\(recipe.recipeIngredient.count) ingredients", systemImage: "leaf")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if recipe.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    private var subtitle: String? {
        [recipe.recipeCuisine, recipe.recipeCategory]
            .compactMap { $0 }
            .joined(separator: " · ")
            .nilIfEmpty
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

#Preview {
    List {
        RecipeRowView(recipe: Recipe(
            name: "Classic Tomato Pasta",
            recipeIngredient: ["400g spaghetti", "800g tomatoes", "garlic", "olive oil"],
            recipeCategory: "Dinner",
            recipeCuisine: "Italian",
            totalTime: "PT30M",
            isFavorite: true
        ))
        RecipeRowView(recipe: Recipe(
            name: "Egg Fried Rice",
            recipeIngredient: ["rice", "eggs", "soy sauce"],
            recipeCategory: "Dinner",
            recipeCuisine: "Asian",
            totalTime: "PT15M"
        ))
    }
}
