import SwiftUI
import SwiftData

/// Root navigation view using NavigationSplitView for adaptive layout.
/// Renders as a sidebar on iPad/Mac and collapses to a tab bar on iPhone.
struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            compactLayout
        } else {
            regularLayout
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        TabView {
            Tab("Recipes", systemImage: "list.bullet") {
                RecipeListView()
            }
            Tab("What Can I Make?", systemImage: "magnifyingglass") {
                WhatCanIMakeComingSoonView()
            }
            Tab("Add Recipe", systemImage: "plus") {
                AddRecipeComingSoonView()
            }
            Tab("Books", systemImage: "book") {
                BookListView()
            }
        }
    }

    // MARK: - Regular Layout (iPad / Mac)

    @State private var selectedSection: SidebarSection? = .recipes

    private var regularLayout: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: $selectedSection) { section in
                Label(section.title, systemImage: section.icon)
            }
            .navigationTitle("RecipeVault")
        } detail: {
            switch selectedSection {
            case .recipes:
                RecipeListView()
            case .whatCanIMake:
                WhatCanIMakeComingSoonView()
            case .addRecipe:
                AddRecipeComingSoonView()
            case .books:
                BookListView()
            case nil:
                ContentUnavailableView("Select a Section",
                                       systemImage: "fork.knife",
                                       description: Text("Choose a section from the sidebar."))
            }
        }
    }
}

// MARK: - Sidebar Sections

enum SidebarSection: String, CaseIterable, Identifiable {
    case recipes
    case whatCanIMake
    case addRecipe
    case books

    var id: Self { self }

    var title: String {
        switch self {
        case .recipes: "Recipes"
        case .whatCanIMake: "What Can I Make?"
        case .addRecipe: "Add Recipe"
        case .books: "Books"
        }
    }

    var icon: String {
        switch self {
        case .recipes: "list.bullet"
        case .whatCanIMake: "magnifyingglass"
        case .addRecipe: "plus"
        case .books: "book"
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, Book.self, Ingredient.self], inMemory: true)
}
