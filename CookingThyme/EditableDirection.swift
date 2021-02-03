//
//  EditableDirection.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/1/20.
//

import SwiftUI
import GRDB

struct EditableDirection: View {
    @EnvironmentObject var recipe: RecipeVM
    var index: Int
    @Binding var editingIndex: Int?

    var autocapitalization: UITextAutocapitalizationType = .sentences
    @State private var dummyBinding: String = ""
    
    var body: some View {
//        ZStack {
//            HStack {
//                RecipeControls.ReadDirection(direction: getDirection())
//                    .padding()
//
//                Spacer()
//            }
//            .opacity(editingIndex != index ? 1 : 0)
//
//            if editingIndex == index {
//                VStack {
//                    Spacer()
//
////                    TextField(getDirection(), text: getDirectionBinding())
//                    EditableTextView(textBinding: getDirectionBinding(), isFirstResponder: true)
//                        .onChange(of: getDirection()) { value in
//                            if value.hasSuffix("\n") {
//                                commitDirection()
//                                withAnimation {
//                                    // unfocus
//                                    unfocusEditable()
//                                    editingIndex = nil
//                                }
//                            }
//                        }
//
//                    Spacer()
//                }
//                .padding(.horizontal)
//            }
//        }
//        .simultaneousGesture(
//            TapGesture(count: 1).onEnded { _ in
//                unfocusEditable()
//                editingIndex = index
//            }
//        )
        
        ZStack {
            HStack(spacing: 0) {
                Text(getDirection())
                    .opacity(0)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.all, 8)
            }

            TextEditor(text: getDirectionBinding())
                .autocapitalization(autocapitalization)
        }
    }
    
    func commitDirection() {
        if index < recipe.tempDirections.count {
            recipe.tempDirections[index].direction.removeLast(1)
        }
    }
    
    func getDirectionBinding() -> Binding<String> {
        if index < recipe.tempDirections.count {
            return $recipe.tempDirections[index].direction
        }
        return $dummyBinding
    }
    
    func getDirection() -> String {
        if index < recipe.tempDirections.count {
            return recipe.tempDirections[index].direction
        }
        return ""
    }
}

//struct EditableDirection_Previews: PreviewProvider {
//    static var previews: some View {
//        EditableDirection(index: 0)
//            .environmentObject(RecipeVM(recipe: Recipe(
//                                        name: "Water",
//                                        ingredients: [
//                                            Ingredient(name: "water", amount: 1.05, unitName: UnitOfMeasurement.cup),
//                                            Ingredient(name: "water", amount: 2.1, unitName: UnitOfMeasurement.cup),
//                                            Ingredient(name: "water", amount: 1.3, unitName: UnitOfMeasurement.cup),
//                                            Ingredient(name: "water", amount: 1.8, unitName: UnitOfMeasurement.cup),
//                                            Ingredient(name: "water", amount: 1.95, unitName: UnitOfMeasurement.cup)
//                                        ],
//                                            directions: [Direction(step: 0, recipeId: 0, direction: "Fetch a pail of water")],
//                                            images: [RecipeImage](),
//                                        servings: 1),
//                                        category: RecipeCategoryVM(category: RecipeCategory(name: "All", recipeCollectionId: 0), collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
//                                ))
//    }
//}
