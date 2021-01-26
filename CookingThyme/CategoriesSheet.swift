//
//  CategoriesSheet.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/25/21.
//

import SwiftUI

struct CategoriesSheet: View {
    @EnvironmentObject var collection: RecipeCollectionVM
    var actionWord: String
    @Binding var isPresented: Bool
    var onAction: (Int) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(collection.categories, id: \.self) { category in
                        Button(action: {
                            onAction(category.id)
                            isPresented = false
                        }) {
                            Text("\(category.name)")
                                .foregroundColor(.black)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("\(actionWord) to Category", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                    }
            )
        }
    }
}

//struct CategoriesSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesSheet()
//    }
//}
