import SwiftUI
import SwiftData

/// Displays the cookbook collection with recipe counts.
struct BookListView: View {
    @Query(sort: \Book.title) private var books: [Book]

    var body: some View {
        NavigationStack {
            List(books) { book in
                NavigationLink(value: book) {
                    BookRowView(book: book)
                }
            }
            .navigationTitle("Books")
            .navigationDestination(for: Book.self) { book in
                BookRecipeListView(book: book)
            }
            .overlay {
                if books.isEmpty {
                    ContentUnavailableView("No Books", systemImage: "book",
                                           description: Text("Books will appear here when you add recipes from cookbooks."))
                }
            }
        }
    }
}

// MARK: - Book Row

/// A single row showing a book with its recipe count.
private struct BookRowView: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.title)
                .font(.headline)
            if let author = book.author {
                Text(author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("^[\(book.recipes.count) recipe](inflect: true)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Book Recipe List

/// Shows all recipes from a specific book.
private struct BookRecipeListView: View {
    let book: Book

    var body: some View {
        List(book.recipes.sorted(by: { $0.name < $1.name })) { recipe in
            NavigationLink(value: recipe) {
                RecipeRowView(recipe: recipe)
            }
        }
        .navigationTitle(book.title)
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
        .overlay {
            if book.recipes.isEmpty {
                ContentUnavailableView("No Recipes", systemImage: "fork.knife",
                                       description: Text("No recipes from this book yet."))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BookListView()
        .modelContainer(for: [Recipe.self, Book.self, Ingredient.self], inMemory: true)
}
