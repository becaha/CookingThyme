//
//  RecipeTextView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

// TODO: keep plaace as switch from rercipe text to recipe
// TODO: scripture app lik
// TODO: text iss selectable and copiable
struct RecipeTextView: View {
    @EnvironmentObject var recipe: RecipeVM
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            if recipe.recipeText != nil {
                ScrollView {
                    Text("Recipe Text")
                    
                    Text("\(recipe.recipeText!)")
                }
                .foregroundColor(.black)
            }
        }
        .padding()
    }
}

//struct RecipeTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeTextView()
//    }
//}
