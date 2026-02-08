import SwiftUI
import SwiftData

@main
struct RecipeVaultApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Recipe.self,
            Book.self,
            Ingredient.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema
        )
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await loadSeedDataIfNeeded()
                }
        }
        .modelContainer(modelContainer)
    }

    /// Populates the database with sample data on first launch.
    @MainActor
    private func loadSeedDataIfNeeded() {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<Recipe>()
        let count = (try? context.fetchCount(descriptor)) ?? 0

        guard count == 0 else { return }
        SeedData.populate(context: context)
    }
}
