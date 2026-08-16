import Foundation
import Testing
import SwiftData
@testable import RecipeVault

@Suite("RecipeFormViewModel")
struct RecipeFormViewModelTests {

    // MARK: - Initial State

    @Test func initialStateHasOneEmptyIngredientAndInstruction() {
        let vm = RecipeFormViewModel()
        #expect(vm.ingredients.count == 1)
        #expect(vm.ingredients[0].text == "")
        #expect(vm.instructions.count == 1)
        #expect(vm.instructions[0].text == "")
        #expect(vm.tags.isEmpty)
    }

    // MARK: - Validation

    @Test func canSaveIsFalseWhenTitleEmpty() {
        let vm = RecipeFormViewModel()
        #expect(vm.canSave == false)
    }

    @Test func canSaveIsFalseWhenTitleOnlyWhitespace() {
        let vm = RecipeFormViewModel()
        vm.title = "   "
        #expect(vm.canSave == false)
    }

    @Test func canSaveIsTrueWhenTitleNonEmpty() {
        let vm = RecipeFormViewModel()
        vm.title = "Pasta"
        #expect(vm.canSave == true)
    }

    // MARK: - Ingredient Management

    @Test func addIngredientAppendsNewItem() {
        let vm = RecipeFormViewModel()
        let initialCount = vm.ingredients.count
        let newID = vm.addIngredient()
        #expect(vm.ingredients.count == initialCount + 1)
        #expect(vm.ingredients.last?.id == newID)
    }

    @Test func addIngredientAfterInsertsAtCorrectPosition() {
        let vm = RecipeFormViewModel()
        vm.ingredients[0].text = "first"
        vm.addIngredient()
        vm.ingredients[1].text = "third"
        let newID = vm.addIngredient(after: vm.ingredients[0])
        #expect(vm.ingredients[1].id == newID)
        #expect(vm.ingredients[0].text == "first")
        #expect(vm.ingredients[2].text == "third")
    }

    @Test func removeIngredientsAtOffset() {
        let vm = RecipeFormViewModel()
        vm.addIngredient()
        vm.addIngredient()
        let originalCount = vm.ingredients.count
        vm.removeIngredients(at: IndexSet(integer: 0))
        #expect(vm.ingredients.count == originalCount - 1)
    }

    @Test func removeAllIngredientsLeavesOneEmpty() {
        let vm = RecipeFormViewModel()
        vm.removeIngredients(at: IndexSet(integer: 0))
        #expect(vm.ingredients.count == 1)
        #expect(vm.ingredients[0].text == "")
    }

    // MARK: - Instruction Management

    @Test func addInstructionAppendsNewItem() {
        let vm = RecipeFormViewModel()
        let newID = vm.addInstruction()
        #expect(vm.instructions.count == 2)
        #expect(vm.instructions.last?.id == newID)
    }

    @Test func removeAllInstructionsLeavesOneEmpty() {
        let vm = RecipeFormViewModel()
        vm.removeInstructions(at: IndexSet(integer: 0))
        #expect(vm.instructions.count == 1)
        #expect(vm.instructions[0].text == "")
    }

    // MARK: - Tag Management

    @Test func commitTagAddsLowercasedTag() {
        let vm = RecipeFormViewModel()
        vm.currentTagInput = "Pasta"
        let added = vm.commitTag()
        #expect(added == true)
        #expect(vm.tags == ["pasta"])
        #expect(vm.currentTagInput == "")
    }

    @Test func commitTagStripsSpaces() {
        let vm = RecipeFormViewModel()
        vm.currentTagInput = "quick meal"
        let added = vm.commitTag()
        #expect(added == true)
        #expect(vm.tags == ["quickmeal"])
    }

    @Test func commitTagRejectsDuplicates() {
        let vm = RecipeFormViewModel()
        vm.currentTagInput = "pasta"
        vm.commitTag()
        vm.currentTagInput = "pasta"
        let added = vm.commitTag()
        #expect(added == false)
        #expect(vm.tags.count == 1)
    }

    @Test func commitTagRejectsEmpty() {
        let vm = RecipeFormViewModel()
        vm.currentTagInput = "   "
        let added = vm.commitTag()
        #expect(added == false)
        #expect(vm.tags.isEmpty)
    }

    @Test func removeTagDeletesCorrectTag() {
        let vm = RecipeFormViewModel()
        vm.currentTagInput = "pasta"
        vm.commitTag()
        vm.currentTagInput = "italian"
        vm.commitTag()
        vm.removeTag("pasta")
        #expect(vm.tags == ["italian"])
    }

    // MARK: - Build Recipe

    @Test func buildRecipeStripsEmptyRows() {
        let vm = RecipeFormViewModel()
        vm.title = "Test"
        vm.ingredients[0].text = "400g spaghetti"
        vm.addIngredient() // empty trailing row
        let recipe = vm.buildRecipe()
        #expect(recipe.recipeIngredient.count == 1)
        #expect(recipe.recipeIngredient[0] == "400g spaghetti")
    }

    @Test func buildRecipeNormalizesIngredients() {
        let vm = RecipeFormViewModel()
        vm.title = "Test"
        vm.ingredients[0].text = "2cl lemon juice"
        let recipe = vm.buildRecipe()
        #expect(recipe.normalizedIngredients[0] == "lemon juice")
    }

    @Test func buildRecipeNormalizesDisplaySpacing() {
        let vm = RecipeFormViewModel()
        vm.title = "Test"
        vm.ingredients[0].text = "400 g spaghetti"
        let recipe = vm.buildRecipe()
        #expect(recipe.recipeIngredient[0] == "400g spaghetti")
    }

    @Test func buildRecipeBuildsDurations() {
        let vm = RecipeFormViewModel()
        vm.title = "Test"
        vm.prepHours = 0
        vm.prepMinutes = 15
        vm.cookHours = 1
        vm.cookMinutes = 0
        let recipe = vm.buildRecipe()
        #expect(recipe.prepTime == "PT15M")
        #expect(recipe.cookTime == "PT1H")
        #expect(recipe.totalTime == "PT1H15M")
    }

    @Test func buildRecipeConvertsEmptyStringsToNil() {
        let vm = RecipeFormViewModel()
        vm.title = "Test"
        vm.cuisine = ""
        vm.category = "  "
        let recipe = vm.buildRecipe()
        #expect(recipe.recipeCuisine == nil)
        #expect(recipe.recipeCategory == nil)
    }

    @Test func buildRecipeSetsSourceTypeToManual() {
        let vm = RecipeFormViewModel()
        vm.title = "Test"
        let recipe = vm.buildRecipe()
        #expect(recipe.source == .manual)
    }

    // MARK: - Populate (Edit Mode)

    @Test func populateFillsAllFields() {
        let original = Recipe(
            name: "Pasta",
            recipeDescription: "A tasty pasta",
            recipeIngredient: ["400g spaghetti", "2 cloves garlic"],
            recipeInstructions: ["Boil water", "Cook pasta"],
            recipeCategory: "Dinner",
            recipeCuisine: "Italian",
            recipeYield: "4 servings",
            prepTime: "PT10M",
            cookTime: "PT20M",
            keywords: ["pasta", "italian"]
        )

        let vm = RecipeFormViewModel()
        vm.populate(from: original)

        #expect(vm.title == "Pasta")
        #expect(vm.recipeDescription == "A tasty pasta")
        #expect(vm.ingredients.count == 2)
        #expect(vm.ingredients[0].text == "400g spaghetti")
        #expect(vm.ingredients[1].text == "2 cloves garlic")
        #expect(vm.instructions.count == 2)
        #expect(vm.instructions[0].text == "Boil water")
        #expect(vm.instructions[1].text == "Cook pasta")
        #expect(vm.category == "Dinner")
        #expect(vm.cuisine == "Italian")
        #expect(vm.servings == "4 servings")
        #expect(vm.prepHours == 0)
        #expect(vm.prepMinutes == 10)
        #expect(vm.cookHours == 0)
        #expect(vm.cookMinutes == 20)
        #expect(vm.tags == ["pasta", "italian"])
    }

    @Test func populateHandlesEmptyRecipe() {
        let original = Recipe(name: "Minimal")
        let vm = RecipeFormViewModel()
        vm.populate(from: original)
        #expect(vm.title == "Minimal")
        #expect(vm.ingredients.count == 1)
        #expect(vm.ingredients[0].text == "")
        #expect(vm.instructions.count == 1)
        #expect(vm.instructions[0].text == "")
        #expect(vm.tags.isEmpty)
    }
}
