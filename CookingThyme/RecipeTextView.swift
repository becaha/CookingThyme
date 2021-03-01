//
//  RecipeTextView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct RecipeTextView: View {
    @EnvironmentObject var recipe: RecipeVM
    var fromURL: Bool
    
    @State var recipeText: String = ""

    var body: some View {
        VStack {
            if recipe.recipeText != nil {
                HStack {
                    (Text("Recipe Text") + (!fromURL ? Text(" by Google Vision"): Text("")))
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
