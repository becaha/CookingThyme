//
//  CategoriesSheet.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/25/21.
//

import SwiftUI

struct CategoriesSheet: View {
    @EnvironmentObject var collection: RecipeCollectionVM

    var currentCategoryId: Int?
    var actionWord: String
    @Binding var isPresented: Bool
    var onAction: (Int) -> Void
    var onRemove: (Int) -> Void
    
    @State private var selectedId: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                if collection.categories.count == 1, collection.categories[0].name == "All" {
                    HStack {
                        Spacer()
                        
                        Text("No Categories Found.")
                        
                        Spacer()
                    }
                    .padding()
                }
                
                List {
                    ForEach(collection.categories, id: \.self) { category in
                        if category.name != "All" || actionWord == "Save" {
                            Button(action: {
                                withAnimation {
                                    selectedId = category.id
                                
                                    // if category is the current category, remove it
                                    if category.id == currentCategoryId {
                                        onRemove(category.id)
                                        selectedId = nil
                                    }
                                    else {
                                        onAction(category.id)
                                    }
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isPresented = false
                                }
                            }) {
                                HStack {
                                    CircleImage()
                                        .shadow(color: Color.gray, radius: 1)
                                        .environmentObject(category)
                                
                                    Text("\(category.name)")
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    if selectedId == category.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
            .onAppear {
                if let currentCategoryId = self.currentCategoryId {
                    selectedId = currentCategoryId
                }
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
            .navigationBarColor(offWhiteUIColor())
        }
    }
}

//struct CategoriesSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesSheet()
//    }
//}
