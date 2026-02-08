import SwiftUI
import SwiftData

/// Displays the full detail of a single recipe.
struct RecipeDetailView: View {
    @Bindable var recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                metadataGrid
                ingredientsSection
                instructionsSection
                sourceSection
                keywordsSection
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    recipe.isFavorite.toggle()
                    recipe.updatedAt = Date()
                } label: {
                    Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(recipe.isFavorite ? .yellow : .secondary)
                }
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        if let description = recipe.recipeDescription {
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
        }

        if let tags = tagLine {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.fill.tertiary)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var tagLine: [String]? {
        let tags = [recipe.recipeCuisine, recipe.recipeCategory].compactMap { $0 }
        return tags.isEmpty ? nil : tags
    }

    // MARK: - Metadata Grid

    @ViewBuilder
    private var metadataGrid: some View {
        let items = metadataItems
        if !items.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(items, id: \.label) { item in
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.title3)
                            .foregroundStyle(.tint)
                        Text(item.value)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(item.label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(.fill.quinary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var metadataItems: [(icon: String, value: String, label: String)] {
        var items: [(String, String, String)] = []
        if let prep = DurationFormatter.formatted(recipe.prepTime) {
            items.append(("clock", prep, "Prep"))
        }
        if let cook = DurationFormatter.formatted(recipe.cookTime) {
            items.append(("flame", cook, "Cook"))
        }
        if let total = DurationFormatter.formatted(recipe.totalTime) {
            items.append(("clock.badge.checkmark", total, "Total"))
        }
        if let yield = recipe.recipeYield {
            items.append(("person.2", yield, "Serves"))
        }
        return items
    }

    // MARK: - Ingredients

    @ViewBuilder
    private var ingredientsSection: some View {
        if !recipe.recipeIngredient.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Ingredients", count: recipe.recipeIngredient.count)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(recipe.recipeIngredient, id: \.self) { ingredient in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundStyle(.secondary)
                            Text(ingredient)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Instructions

    @ViewBuilder
    private var instructionsSection: some View {
        if !recipe.recipeInstructions.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Instructions", count: recipe.recipeInstructions.count)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(recipe.recipeInstructions.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.accentColor)
                                .clipShape(Circle())

                            Text(step)
                                .font(.body)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Source

    @ViewBuilder
    private var sourceSection: some View {
        let hasSource = recipe.source != .manual || recipe.notes != nil
        if hasSource {
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Source")

                switch recipe.source {
                case .book:
                    if let book = recipe.book {
                        HStack(spacing: 6) {
                            Image(systemName: "book")
                                .foregroundStyle(.secondary)
                            Text(book.title)
                                .fontWeight(.medium)
                            if let author = book.author {
                                Text("by \(author)")
                                    .foregroundStyle(.secondary)
                            }
                            if let page = recipe.sourcePageNumber {
                                Text("· p. \(page)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(.subheadline)
                    }
                case .url:
                    if let urlString = recipe.sourceURL {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                                .foregroundStyle(.secondary)
                            Text(urlString)
                                .font(.subheadline)
                                .foregroundStyle(.tint)
                                .lineLimit(1)
                        }
                    }
                case .manual:
                    EmptyView()
                }

                if let notes = recipe.notes {
                    Text(notes)
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.fill.quinary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    // MARK: - Keywords

    @ViewBuilder
    private var keywordsSection: some View {
        if !recipe.keywords.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Keywords")

                FlowLayout(spacing: 6) {
                    ForEach(recipe.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.fill.tertiary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, count: Int? = nil) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            if let count {
                Text("(\(count))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Flow Layout

/// A simple wrapping layout for tags and keywords.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                          proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            name: "Classic Tomato Pasta",
            recipeDescription: "A simple, classic Italian pasta with a rich tomato sauce, fresh basil, and parmesan.",
            recipeIngredient: ["400g spaghetti", "800g canned whole tomatoes", "4 cloves garlic", "3 tbsp olive oil", "Fresh basil", "50g parmesan"],
            recipeInstructions: [
                "Bring a large pot of salted water to a boil and cook spaghetti.",
                "Heat olive oil, add garlic and cook until fragrant.",
                "Add tomatoes, simmer for 15 minutes.",
                "Toss pasta with sauce, serve with basil and parmesan.",
            ],
            recipeCategory: "Dinner",
            recipeCuisine: "Italian",
            recipeYield: "4 servings",
            prepTime: "PT10M",
            cookTime: "PT20M",
            totalTime: "PT30M",
            keywords: ["pasta", "tomato", "italian", "quick", "vegetarian"],
            isFavorite: true
        ))
    }
}
