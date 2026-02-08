import Foundation
import SwiftData
import os

/// Populates the database with sample data for development.
struct SeedData {
    private static let logger = Logger(subsystem: "com.recipevault.app", category: "SeedData")

    /// Populates the model context with sample books, recipes, and ingredients.
    /// Should only be called when the database is empty (first launch).
    @MainActor
    static func populate(context: ModelContext) {
        logger.info("Populating seed data...")

        // MARK: - Books

        let saltFatAcidHeat = Book(title: "Salt, Fat, Acid, Heat", author: "Samin Nosrat")
        let theWok = Book(title: "The Wok", author: "J. Kenji López-Alt")
        let ottolenghiSimple = Book(title: "Ottolenghi Simple", author: "Yotam Ottolenghi")

        context.insert(saltFatAcidHeat)
        context.insert(theWok)
        context.insert(ottolenghiSimple)

        // MARK: - Recipes

        let classicTomatoPasta = Recipe(
            name: "Classic Tomato Pasta",
            recipeDescription: "A simple, classic Italian pasta with a rich tomato sauce, fresh basil, and parmesan.",
            recipeIngredient: [
                "400g spaghetti",
                "800g canned whole tomatoes",
                "4 cloves garlic, minced",
                "3 tbsp olive oil",
                "1 bunch fresh basil",
                "50g parmesan, grated",
                "Salt to taste",
                "1 tsp black pepper",
            ],
            normalizedIngredients: ["spaghetti", "tomato", "garlic", "olive oil", "basil", "parmesan", "salt", "black pepper"],
            recipeInstructions: [
                "Bring a large pot of salted water to a boil and cook spaghetti according to package directions.",
                "Heat olive oil in a large pan over medium heat. Add garlic and cook until fragrant, about 1 minute.",
                "Add canned tomatoes, breaking them up with a spoon. Season with salt and pepper.",
                "Simmer the sauce for 15 minutes, stirring occasionally.",
                "Toss the cooked pasta with the sauce. Serve topped with fresh basil and grated parmesan.",
            ],
            recipeCategory: "Dinner",
            recipeCuisine: "Italian",
            recipeYield: "4 servings",
            prepTime: "PT10M",
            cookTime: "PT20M",
            totalTime: "PT30M",
            keywords: ["pasta", "tomato", "italian", "quick", "vegetarian"],
            author: "Samin Nosrat",
            sourceType: .book,
            sourcePageNumber: 234,
            book: saltFatAcidHeat
        )

        let chickenStirFry = Recipe(
            name: "Chicken Stir-Fry",
            recipeDescription: "A quick and flavorful Asian-style stir-fry with tender chicken and crisp vegetables.",
            recipeIngredient: [
                "500g chicken breast, sliced thin",
                "3 tbsp soy sauce",
                "1 tbsp fresh ginger, grated",
                "3 cloves garlic, minced",
                "2 cups broccoli florets",
                "1 red bell pepper, sliced",
                "2 cups cooked rice",
                "1 tbsp sesame oil",
                "1 tbsp cornstarch",
            ],
            normalizedIngredients: ["chicken breast", "soy sauce", "ginger", "garlic", "broccoli", "bell pepper", "rice", "sesame oil", "cornstarch"],
            recipeInstructions: [
                "Toss chicken slices with soy sauce and cornstarch. Let marinate for 10 minutes.",
                "Heat sesame oil in a wok over high heat.",
                "Stir-fry chicken until golden, about 4 minutes. Remove and set aside.",
                "Add garlic and ginger to the wok, cook for 30 seconds.",
                "Add broccoli and bell pepper. Stir-fry for 3 minutes until crisp-tender.",
                "Return chicken to the wok, toss to combine. Serve over rice.",
            ],
            recipeCategory: "Dinner",
            recipeCuisine: "Asian",
            recipeYield: "4 servings",
            prepTime: "PT15M",
            cookTime: "PT15M",
            totalTime: "PT30M",
            keywords: ["chicken", "stir-fry", "asian", "wok", "quick"],
            author: "J. Kenji López-Alt",
            sourceType: .book,
            sourcePageNumber: 112,
            book: theWok
        )

        let roastedCauliflower = Recipe(
            name: "Roasted Cauliflower with Tahini",
            recipeDescription: "Crispy roasted cauliflower drizzled with a tangy tahini-lemon dressing and fresh herbs.",
            recipeIngredient: [
                "1 large head cauliflower, cut into florets",
                "3 tbsp tahini",
                "1 lemon, juiced",
                "2 cloves garlic, minced",
                "3 tbsp olive oil",
                "2 tbsp fresh parsley, chopped",
                "1 tsp cumin",
                "Salt to taste",
            ],
            normalizedIngredients: ["cauliflower", "tahini", "lemon", "garlic", "olive oil", "parsley", "cumin", "salt"],
            recipeInstructions: [
                "Preheat oven to 220°C (425°F).",
                "Toss cauliflower florets with olive oil, cumin, and salt. Spread on a baking sheet.",
                "Roast for 25-30 minutes until golden and crispy at the edges.",
                "Whisk together tahini, lemon juice, garlic, and a splash of water to make the dressing.",
                "Drizzle the tahini dressing over roasted cauliflower and garnish with fresh parsley.",
            ],
            recipeCategory: "Side",
            recipeCuisine: "Mediterranean",
            recipeYield: "4 servings",
            prepTime: "PT10M",
            cookTime: "PT30M",
            totalTime: "PT40M",
            keywords: ["cauliflower", "tahini", "mediterranean", "roasted", "vegetarian", "vegan"],
            author: "Yotam Ottolenghi",
            sourceType: .book,
            sourcePageNumber: 78,
            book: ottolenghiSimple
        )

        let blackBeanSoup = Recipe(
            name: "Quick Black Bean Soup",
            recipeDescription: "A hearty, warming black bean soup with cumin and lime — ready in under 30 minutes.",
            recipeIngredient: [
                "2 cans (400g each) black beans, drained and rinsed",
                "1 medium onion, diced",
                "3 cloves garlic, minced",
                "2 tsp cumin",
                "3 cups chicken stock",
                "1 lime, juiced",
                "2 tbsp fresh cilantro, chopped",
                "2 tbsp sour cream",
            ],
            normalizedIngredients: ["black bean", "onion", "garlic", "cumin", "chicken stock", "lime", "cilantro", "sour cream"],
            recipeInstructions: [
                "Heat a drizzle of oil in a large pot over medium heat. Sauté onion until softened, about 5 minutes.",
                "Add garlic and cumin, cook for 1 minute until fragrant.",
                "Add black beans and chicken stock. Bring to a boil, then reduce heat and simmer for 15 minutes.",
                "Use an immersion blender to partially blend the soup, leaving some beans whole for texture.",
                "Stir in lime juice. Serve topped with sour cream and fresh cilantro.",
            ],
            recipeCategory: "Soup",
            recipeCuisine: "Mexican",
            recipeYield: "4 servings",
            prepTime: "PT5M",
            cookTime: "PT25M",
            totalTime: "PT30M",
            keywords: ["soup", "black bean", "quick", "comfort food"],
            sourceType: .url,
            sourceURL: "https://example.com/bean-soup"
        )

        let eggFriedRice = Recipe(
            name: "Egg Fried Rice",
            recipeDescription: "Classic Chinese egg fried rice with wok hei — the key is cold rice and a very hot wok.",
            recipeIngredient: [
                "4 cups cold cooked rice",
                "3 large eggs, beaten",
                "2 tbsp soy sauce",
                "1 tbsp sesame oil",
                "3 spring onions, sliced",
                "2 cloves garlic, minced",
                "1/2 cup peas",
                "1 medium carrot, diced small",
            ],
            normalizedIngredients: ["rice", "egg", "soy sauce", "sesame oil", "spring onion", "garlic", "pea", "carrot"],
            recipeInstructions: [
                "Heat sesame oil in a wok over high heat until smoking.",
                "Add beaten eggs, scramble quickly, and break into small pieces. Remove and set aside.",
                "Add garlic, peas, and carrot to the wok. Stir-fry for 2 minutes.",
                "Add cold rice, pressing it flat against the wok to get crispy bits. Stir-fry for 3 minutes.",
                "Add soy sauce and toss to coat evenly.",
                "Return eggs to the wok, add spring onions, and toss to combine. Serve immediately.",
            ],
            recipeCategory: "Dinner",
            recipeCuisine: "Asian",
            recipeYield: "3 servings",
            prepTime: "PT5M",
            cookTime: "PT10M",
            totalTime: "PT15M",
            keywords: ["fried rice", "egg", "asian", "wok", "quick", "vegetarian"],
            author: "J. Kenji López-Alt",
            sourceType: .book,
            sourcePageNumber: 89,
            book: theWok
        )

        let hummus = Recipe(
            name: "Hummus from Scratch",
            recipeDescription: "Ultra-smooth homemade hummus with tahini, lemon, and a drizzle of olive oil.",
            recipeIngredient: [
                "2 cans (400g each) chickpeas, drained and rinsed",
                "4 tbsp tahini",
                "2 lemons, juiced",
                "2 cloves garlic",
                "3 tbsp olive oil",
                "1 tsp cumin",
                "Salt to taste",
                "1/2 tsp paprika for garnish",
            ],
            normalizedIngredients: ["chickpea", "tahini", "lemon", "garlic", "olive oil", "cumin", "salt", "paprika"],
            recipeInstructions: [
                "Add chickpeas, tahini, lemon juice, garlic, cumin, and salt to a food processor.",
                "Blend until smooth, scraping down the sides as needed. Add a splash of cold water if too thick.",
                "Taste and adjust seasoning — add more lemon, salt, or garlic as needed.",
                "Transfer to a serving bowl, drizzle with olive oil, and sprinkle with paprika.",
            ],
            recipeCategory: "Appetizer",
            recipeCuisine: "Mediterranean",
            recipeYield: "6 servings",
            prepTime: "PT10M",
            totalTime: "PT10M",
            keywords: ["hummus", "chickpea", "mediterranean", "dip", "vegan"],
            sourceType: .manual
        )

        let duckBreast = Recipe(
            name: "Duck Breast with Cherry Sauce",
            recipeDescription: "Pan-seared duck breast with a rich, glossy cherry and red wine sauce.",
            recipeIngredient: [
                "2 duck breasts, skin scored",
                "200g fresh cherries, pitted and halved",
                "150ml red wine",
                "30g butter",
                "2 sprigs fresh thyme",
                "Salt to taste",
                "1 tsp black pepper",
                "1 tbsp sugar",
            ],
            normalizedIngredients: ["duck breast", "cherry", "red wine", "butter", "thyme", "salt", "black pepper", "sugar"],
            recipeInstructions: [
                "Score the duck skin in a crosshatch pattern. Season generously with salt and pepper.",
                "Place duck breasts skin-side down in a cold pan. Turn heat to medium and render the fat for 8-10 minutes.",
                "Flip and cook for 3-4 minutes for medium-rare. Rest for 5 minutes.",
                "In the same pan, add cherries, sugar, and thyme. Cook for 2 minutes.",
                "Pour in red wine and simmer until reduced by half, about 5 minutes.",
                "Swirl in butter to finish the sauce. Slice duck and serve with the cherry sauce.",
            ],
            recipeCategory: "Dinner",
            recipeCuisine: "French",
            recipeYield: "2 servings",
            prepTime: "PT10M",
            cookTime: "PT25M",
            totalTime: "PT35M",
            keywords: ["duck", "cherry", "french", "special occasion", "date night"],
            sourceType: .url,
            sourceURL: "https://example.com/duck-cherry"
        )

        let caesarSalad = Recipe(
            name: "Caesar Salad",
            recipeDescription: "Classic Caesar salad with a homemade dressing, crunchy croutons, and shaved parmesan.",
            recipeIngredient: [
                "2 heads romaine lettuce, chopped",
                "50g parmesan, shaved",
                "1 cup croutons",
                "2 large eggs (for dressing)",
                "4 anchovy fillets",
                "2 cloves garlic",
                "1 lemon, juiced",
                "4 tbsp olive oil",
                "1 tsp dijon mustard",
            ],
            normalizedIngredients: ["romaine lettuce", "parmesan", "crouton", "egg", "anchovy", "garlic", "lemon", "olive oil", "dijon mustard"],
            recipeInstructions: [
                "Make the dressing: blend eggs, anchovies, garlic, lemon juice, and mustard in a food processor.",
                "With the motor running, slowly drizzle in olive oil until emulsified.",
                "Toss chopped romaine with the dressing until well coated.",
                "Top with croutons and shaved parmesan. Serve immediately.",
            ],
            recipeCategory: "Salad",
            recipeCuisine: "American",
            recipeYield: "4 servings",
            prepTime: "PT15M",
            totalTime: "PT15M",
            keywords: ["salad", "caesar", "classic", "american"],
            sourceType: .manual
        )

        let recipes = [classicTomatoPasta, chickenStirFry, roastedCauliflower,
                       blackBeanSoup, eggFriedRice, hummus, duckBreast, caesarSalad]
        for recipe in recipes {
            context.insert(recipe)
        }

        // MARK: - Ingredients

        let ingredients: [(String, IngredientCategory, [String])] = [
            // Proteins
            ("chicken breast", .protein, ["chicken"]),
            ("duck breast", .protein, ["duck"]),
            ("egg", .protein, ["eggs"]),
            ("anchovy", .protein, ["anchovies", "anchovy fillet"]),

            // Vegetables
            ("tomato", .vegetable, ["tomatoes", "canned tomato"]),
            ("garlic", .vegetable, []),
            ("onion", .vegetable, []),
            ("broccoli", .vegetable, []),
            ("bell pepper", .vegetable, ["capsicum", "red pepper"]),
            ("cauliflower", .vegetable, []),
            ("romaine lettuce", .vegetable, ["romaine", "cos lettuce"]),
            ("carrot", .vegetable, ["carrots"]),
            ("pea", .vegetable, ["peas", "green pea"]),
            ("spring onion", .vegetable, ["scallion", "green onion"]),

            // Fruits
            ("lemon", .fruit, ["lemons"]),
            ("lime", .fruit, ["limes"]),
            ("cherry", .fruit, ["cherries"]),

            // Dairy
            ("parmesan", .dairy, ["parmigiano", "parmigiano-reggiano"]),
            ("butter", .dairy, []),
            ("sour cream", .dairy, []),

            // Grains
            ("spaghetti", .grain, ["pasta"]),
            ("rice", .grain, ["cooked rice", "white rice"]),
            ("crouton", .grain, ["croutons"]),

            // Pantry Staples
            ("olive oil", .pantryStaple, []),
            ("sesame oil", .pantryStaple, []),
            ("soy sauce", .pantryStaple, []),
            ("cornstarch", .pantryStaple, ["corn starch"]),
            ("tahini", .pantryStaple, []),
            ("chickpea", .pantryStaple, ["chickpeas", "garbanzo", "garbanzo bean"]),
            ("black bean", .pantryStaple, ["black beans"]),
            ("chicken stock", .pantryStaple, ["chicken broth"]),
            ("red wine", .pantryStaple, []),
            ("sugar", .pantryStaple, []),
            ("dijon mustard", .condiment, ["dijon"]),

            // Herbs
            ("basil", .herb, ["fresh basil"]),
            ("parsley", .herb, ["fresh parsley"]),
            ("cilantro", .herb, ["coriander", "fresh cilantro"]),
            ("thyme", .herb, ["fresh thyme"]),

            // Spices
            ("salt", .spice, ["sea salt", "kosher salt"]),
            ("black pepper", .spice, ["pepper"]),
            ("cumin", .spice, ["ground cumin"]),
            ("paprika", .spice, []),
            ("ginger", .spice, ["fresh ginger"]),
        ]

        for (name, category, aliases) in ingredients {
            let ingredient = Ingredient(name: name, category: category, aliases: aliases)
            context.insert(ingredient)
        }

        logger.info("Seed data populated: \(recipes.count) recipes, 3 books, \(ingredients.count) ingredients.")
    }
}
