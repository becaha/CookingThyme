//
//  RecipeTextView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct RecipeTextView: View {
    @EnvironmentObject var recipe: RecipeVM
    
    @State var recipeText: String = "ok this iis a test"
    @State var test = "test"

    var body: some View {
        VStack {
            if recipe.recipeText != nil {
                HStack {
                    Text("Recipe Text by Google Cloud Vision")
                        .customFont(style: .subheadline)
                }
                                        
                SelectableTextView(text: $recipeText, isEditable: false, textStyle: UIFont.TextStyle.body)
                    .customFont(style: .subheadline)
            }
        }
        .onAppear {
            if let text = recipe.recipeText {
                recipeText = text
            }
        }
        .foregroundColor(formItemFont())
        .padding()
    }
}

//struct RecipeTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeTextView()
//    }
//}
