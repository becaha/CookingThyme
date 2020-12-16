//
//  ImportedRecipe.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/16/20.
//

import SwiftUI

struct ImportedRecipe: View {
    @Binding var isCreatingRecipe: Bool
    var recipeText: String
    
    var body: some View {
        VStack {
            Text("\(recipeText)")
        }
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
