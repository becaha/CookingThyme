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
        ZStack {
            HStack {
                RecipeControls.ReadIngredientText(getDirection())
                    .padding()

                Spacer()
            }
            .opacity(editingIndex != index ? 1 : 0)

            if editingIndex == index {
                VStack {
                    Spacer()
                    
                    EditableTextView(textBinding: getDirectionBinding(), isFirstResponder: true)
                        .onChange(of: getDirection()) { value in
                            if value.hasSuffix("\n") {
                                commitDirection()
                                withAnimation {
                                    // unfocus
                                    unfocusEditable()
                                    editingIndex = nil
                                }
                            }
                        }
 
                    Spacer()
                }
                .padding(.horizontal)
            }
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

