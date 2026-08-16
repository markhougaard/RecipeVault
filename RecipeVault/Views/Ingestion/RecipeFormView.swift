import SwiftUI
import SwiftData

/// Focus targets for keyboard navigation through the recipe form.
enum RecipeFormField: Hashable {
    case title
    case ingredient(UUID)
    case instruction(UUID)
    case tag
    case recipeDescription
    case cuisine
    case category
    case servings
    case prepHours
    case prepMinutes
    case cookHours
    case cookMinutes
    case notes
}

/// A form for creating or editing a recipe. Supports full keyboard-driven navigation.
///
/// - For **creating**: init with no parameters. Call `onSave` with the new `Recipe`.
/// - For **editing**: init with an existing `Recipe`. Call `onSave` after applying changes.
struct RecipeFormView: View {
    @State private var viewModel: RecipeFormViewModel
    @FocusState private var focusedField: RecipeFormField?
    @Environment(\.dismiss) private var dismiss

    /// The recipe being edited, or `nil` for a new recipe.
    private let existingRecipe: Recipe?

    /// Called when the user taps Save. The closure receives the saved `Recipe`.
    var onSave: ((Recipe) -> Void)?

    init(editing recipe: Recipe? = nil, onSave: ((Recipe) -> Void)? = nil) {
        self.existingRecipe = recipe
        self.onSave = onSave
        let vm = RecipeFormViewModel()
        if let recipe {
            vm.populate(from: recipe)
        }
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
        Form {
            titleSection
            ingredientsSection
            instructionsSection
            tagsSection
            detailsSection
            timeSection
            notesSection
        }
        .navigationTitle(existingRecipe != nil ? "Edit Recipe" : "Add Recipe")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(!viewModel.canSave)
            }
        }
        .onAppear {
            focusedField = .title
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        Section {
            TextField("Recipe name", text: $viewModel.title)
                .focused($focusedField, equals: .title)
                .font(.headline)
                .onSubmit { focusFirstIngredient() }
                .submitLabel(.next)
        }
    }

    // MARK: - Ingredients Section

    private var ingredientsSection: some View {
        Section("Ingredients") {
            ForEach($viewModel.ingredients) { $item in
                TextField("e.g. 400g spaghetti", text: $item.text)
                    .focused($focusedField, equals: .ingredient(item.id))
                    .onSubmit { addIngredientAfter(item) }
                    .submitLabel(.next)
            }
            .onDelete { viewModel.removeIngredients(at: $0) }

            Button {
                let newID = viewModel.addIngredient()
                focusedField = .ingredient(newID)
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle")
            }
        }
    }

    // MARK: - Instructions Section

    private var instructionsSection: some View {
        Section("Instructions") {
            ForEach(Array(viewModel.instructions.enumerated()), id: \.element.id) { index, _ in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .padding(.top, 8)

                    TextField("Step \(index + 1)", text: $viewModel.instructions[index].text, axis: .vertical)
                        .focused($focusedField, equals: .instruction(viewModel.instructions[index].id))
                        .lineLimit(1...10)
                        .onSubmit { addInstructionAfter(viewModel.instructions[index]) }
                        .submitLabel(.next)
                }
            }
            .onDelete { viewModel.removeInstructions(at: $0) }

            Button {
                let newID = viewModel.addInstruction()
                focusedField = .instruction(newID)
            } label: {
                Label("Add Step", systemImage: "plus.circle")
            }
        }
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        Section("Tags") {
            if !viewModel.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(viewModel.tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                                .font(.caption)
                            Button {
                                viewModel.removeTag(tag)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.fill.tertiary)
                        .clipShape(Capsule())
                    }
                }
            }

            TextField("Add tag...", text: $viewModel.currentTagInput)
                .focused($focusedField, equals: .tag)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                .onSubmit {
                    viewModel.commitTag()
                    focusedField = .tag
                }
                .submitLabel(.done)
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        Section("Details") {
            TextField("Description", text: $viewModel.recipeDescription, axis: .vertical)
                .focused($focusedField, equals: .recipeDescription)
                .lineLimit(2...5)

            TextField("Cuisine (e.g. Italian)", text: $viewModel.cuisine)
                .focused($focusedField, equals: .cuisine)

            TextField("Category (e.g. Dinner)", text: $viewModel.category)
                .focused($focusedField, equals: .category)

            TextField("Servings (e.g. 4 servings)", text: $viewModel.servings)
                .focused($focusedField, equals: .servings)
        }
    }

    // MARK: - Time Section

    private var timeSection: some View {
        Section("Time") {
            durationRow(label: "Prep Time", hours: $viewModel.prepHours, minutes: $viewModel.prepMinutes)
            durationRow(label: "Cook Time", hours: $viewModel.cookHours, minutes: $viewModel.cookMinutes)
        }
    }

    private func durationRow(label: String, hours: Binding<Int>, minutes: Binding<Int>) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Picker("Hours", selection: hours) {
                ForEach(0..<25) { h in
                    Text("\(h) hr").tag(h)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()

            Picker("Minutes", selection: minutes) {
                ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                    Text("\(m) min").tag(m)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        Section("Notes") {
            TextField("Personal notes...", text: $viewModel.notes, axis: .vertical)
                .focused($focusedField, equals: .notes)
                .lineLimit(3...10)
        }
    }

    // MARK: - Actions

    private func save() {
        guard viewModel.canSave else { return }

        if let existingRecipe {
            viewModel.applyChanges(to: existingRecipe)
            onSave?(existingRecipe)
        } else {
            let recipe = viewModel.buildRecipe()
            onSave?(recipe)
        }

        dismiss()
    }

    private func focusFirstIngredient() {
        if let first = viewModel.ingredients.first {
            focusedField = .ingredient(first.id)
        }
    }

    private func addIngredientAfter(_ item: FormItem) {
        let newID = viewModel.addIngredient(after: item)
        focusedField = .ingredient(newID)
    }

    private func addInstructionAfter(_ item: FormItem) {
        let newID = viewModel.addInstruction(after: item)
        focusedField = .instruction(newID)
    }
}

// MARK: - Preview

#Preview("Add Recipe") {
    NavigationStack {
        RecipeFormView()
    }
}

#Preview("Edit Recipe") {
    NavigationStack {
        RecipeFormView(editing: Recipe(
            name: "Classic Tomato Pasta",
            recipeDescription: "A simple Italian classic.",
            recipeIngredient: ["400g spaghetti", "800g canned tomatoes", "3 tbsp olive oil"],
            recipeInstructions: ["Boil pasta", "Make sauce", "Combine and serve"],
            recipeCategory: "Dinner",
            recipeCuisine: "Italian",
            recipeYield: "4 servings",
            prepTime: "PT10M",
            cookTime: "PT20M",
            keywords: ["pasta", "italian", "quick"]
        ))
    }
}
