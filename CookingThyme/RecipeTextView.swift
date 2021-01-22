//
//  RecipeTextView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct RecipeTextView: View {
    @EnvironmentObject var recipe: RecipeVM
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                if recipe.recipeText != nil {
                    ScrollView {
                        Text("\(recipe.recipeText!)")
                    }
                    .foregroundColor(.black)
                }
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack {
                        Button(action: {
                            isPresented = false
                        })
                        {
                            Text("Done")
                        }
                    }
            )
        }
    }
}

//struct RecipeTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipeTextView()
//    }
//}
