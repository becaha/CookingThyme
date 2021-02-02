//
//  RecipeTextView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

// TODO: keep plaace as switch from rercipe text to recipe
// TODO: scripture app like
// TODO: make recipe text look cute, rounded corners
struct RecipeTextView: View {
    @EnvironmentObject var recipe: RecipeVM
    
    @State var recipeText: String = "ok this iis a test"
    @State var test = "test"

    var body: some View {
        VStack {
            if recipe.recipeText != nil {
                    Text("Recipe Text")
                                        
                    SelectableTextView(text: $recipeText, isEditable: false, textStyle: UIFont.TextStyle.body)
            }
        }
        .onAppear {
            if let text = recipe.recipeText {
                recipeText = text
            }
        }
        .foregroundColor(.black)
        .padding()
    }
}

//struct RecipeTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeTextView()
//    }
//}
