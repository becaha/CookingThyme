//
//  ImportedRecipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/16/20.
//

import SwiftUI

struct ImportedRecipe: View {
    @EnvironmentObject var recipe: RecipeVM
    @Binding var isCreatingRecipe: Bool
    
    var body: some View {
        VStack {
            if recipe.recipeText != nil {
                ScrollView(.vertical) {
                    Text("\(recipe.recipeText!)")
                }
                .foregroundColor(.black)
            }
            else {
                UIControls.Loading()
                    .padding()
            }
        }
        .background(formBackgroundColor())
        .navigationBarItems(
            leading:
                Button(action: {
                    withAnimation {
                        isCreatingRecipe = false
                    }
                }) {
                    Text("Cancel")
                }
                .padding(.leading, 0)
            ,
            trailing:
                HStack {
                    Button(action: {
//                        saveRecipe()
                    })
                    {
                        Text("Done")
                    }
                }
        )
    }
}

//struct ImportedRecipe_Previews: PreviewProvider {
//    static var previews: some View {
//        ImportedRecipe(recipeText: "hi")
//    }
//}
