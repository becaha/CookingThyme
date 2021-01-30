//
//  CategoriesSheet.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/25/21.
//

import SwiftUI


//TODO: if no categories
struct CategoriesSheet: View {
    @EnvironmentObject var collection: RecipeCollectionVM

    var currentCategoryId: Int?
    var actionWord: String
    @Binding var isPresented: Bool
    var onAction: (Int) -> Void
    
    @State private var selectedId: Int?
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(collection.categories, id: \.self) { category in
                        if category.name != "All" {
                            Button(action: {
                                withAnimation {
                                    selectedId = category.id
                                }
                                onAction(category.id)

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
        }
    }
}

//struct CategoriesSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesSheet()
//    }
//}
