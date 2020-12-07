//
//  HomeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var collection: RecipeCollectionVM
    
    init(collection: RecipeCollectionVM) {
        self.collection = collection
//        UITabBar.appearance().isTranslucent = false
//        UITabBar.appearance().barTintColor = UIColor.systemGreen
    }
    
    var body: some View {
        NavigationView {
            TabView {
                RecipeCollectionView()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Recipe Book")
                    }
                
//                Text("Another Tab")
//                    .tabItem {
//                        Image(systemName: "calendar")
//                        Text("Calendar")
//                    }
                
                Text("Another Tab")
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("Groceries")
                    }
                
                Text("The Last Tab")
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Timer")
                    }
                
            }
            .font(.headline)
            .accentColor(Color(UIColor.systemGreen))
            .navigationBarTitle("Cooking Thyme", displayMode: .inline)
            .background(NavigationBarConfigurator { nc in
                nc.navigationBar.barTintColor = .systemGreen
                nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            })
        }
        .environmentObject(collection)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
    }
}
