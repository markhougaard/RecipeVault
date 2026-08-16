import Testing
@testable import RecipeVault

@Suite("IngredientNormalizer")
struct IngredientNormalizerTests {

    // MARK: - normalize()

    @Test func normalizesQuantityAndUnit() {
        #expect(IngredientNormalizer.normalize("2cl lemon juice") == "lemon juice")
        #expect(IngredientNormalizer.normalize("400g spaghetti") == "spaghetti")
        #expect(IngredientNormalizer.normalize("400 g spaghetti") == "spaghetti")
        #expect(IngredientNormalizer.normalize("3 tbsp olive oil") == "olive oil")
        #expect(IngredientNormalizer.normalize("1 cup flour") == "flour")
    }

    @Test func normalizesFractions() {
        #expect(IngredientNormalizer.normalize("1/2 cup flour") == "flour")
        #expect(IngredientNormalizer.normalize("3/4 tsp salt") == "salt")
    }

    @Test func normalizesFractionWords() {
        #expect(IngredientNormalizer.normalize("half a head of lettuce") == "lettuce")
        #expect(IngredientNormalizer.normalize("quarter cup of sugar") == "sugar")
    }

    @Test func normalizesDescriptiveUnits() {
        #expect(IngredientNormalizer.normalize("3 cloves garlic") == "garlic")
        #expect(IngredientNormalizer.normalize("1 bunch fresh basil") == "basil")
        #expect(IngredientNormalizer.normalize("1 pinch salt") == "salt")
        #expect(IngredientNormalizer.normalize("2 cans tomatoes") == "tomatoes")
    }

    @Test func stripsPreparationInstructions() {
        #expect(IngredientNormalizer.normalize("3 cloves garlic, minced") == "garlic")
        #expect(IngredientNormalizer.normalize("1 onion, diced") == "onion")
    }

    @Test func stripsAdjectives() {
        #expect(IngredientNormalizer.normalize("1 bunch fresh basil") == "basil")
        #expect(IngredientNormalizer.normalize("2 cups dried pasta") == "pasta")
        #expect(IngredientNormalizer.normalize("50g grated parmesan") == "parmesan")
    }

    @Test func handlesPlainIngredients() {
        #expect(IngredientNormalizer.normalize("salt") == "salt")
        #expect(IngredientNormalizer.normalize("black pepper") == "black pepper")
        #expect(IngredientNormalizer.normalize("soy sauce") == "soy sauce")
    }

    @Test func handlesEmptyAndWhitespace() {
        #expect(IngredientNormalizer.normalize("") == "")
        #expect(IngredientNormalizer.normalize("   ") == "")
    }

    @Test func handlesAttachedQuantityUnit() {
        // "2cl" is treated as a single token with quantity+unit
        #expect(IngredientNormalizer.normalize("2cl lemon juice") == "lemon juice")
        #expect(IngredientNormalizer.normalize("500ml water") == "water")
    }

    // MARK: - normalizeDisplaySpacing()

    @Test func collapsesMetricSpacing() {
        #expect(IngredientNormalizer.normalizeDisplaySpacing("400 g spaghetti") == "400g spaghetti")
        #expect(IngredientNormalizer.normalizeDisplaySpacing("2 cl lemon juice") == "2cl lemon juice")
        #expect(IngredientNormalizer.normalizeDisplaySpacing("500 ml water") == "500ml water")
        #expect(IngredientNormalizer.normalizeDisplaySpacing("1 kg flour") == "1kg flour")
    }

    @Test func preservesImperialSpacing() {
        #expect(IngredientNormalizer.normalizeDisplaySpacing("2 cups flour") == "2 cups flour")
        #expect(IngredientNormalizer.normalizeDisplaySpacing("3 tbsp oil") == "3 tbsp oil")
    }

    @Test func preservesAlreadyCollapsed() {
        #expect(IngredientNormalizer.normalizeDisplaySpacing("400g spaghetti") == "400g spaghetti")
        #expect(IngredientNormalizer.normalizeDisplaySpacing("2cl lemon juice") == "2cl lemon juice")
    }
}
