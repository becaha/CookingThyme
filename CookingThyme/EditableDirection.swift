//
//  EditableDirection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI
import GRDB

//TODO: have auto capitalization an option
struct EditableDirection: View {
    @EnvironmentObject var recipe: RecipeVM
    var index: Int
    var autocapitalization: UITextAutocapitalizationType

    @State private var dummyBinding: String = ""
    
    init(index: Int) {
        self.index = index
        self.autocapitalization = .sentences
    }
    
    var body: some View {
        TextEditor(text: getBinding())
            .autocapitalization(autocapitalization)
            .padding(.vertical, -7)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    func getBinding() -> Binding<String> {
        if index < recipe.tempDirections.count {
            return $recipe.tempDirections[index].direction
        }
        return $dummyBinding
    }
}

struct EditableDirection_Previews: PreviewProvider {
    static var previews: some View {
        EditableDirection(index: 0)
            .environmentObject(RecipeVM(recipe: Recipe(
                                        name: "Water",
                                        ingredients: [
                                            Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.cup),
                                            Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.cup),
                                            Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.cup),
                                            Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.cup),
                                            Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.cup)
                                        ],
                                            directions: [Direction(step: 0, recipeId: 0, direction: "Fetch a pail of water")],
                                            images: [RecipeImage](),
                                        servings: 1),
                                        category: RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 0), collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
                                ))
    }
}
