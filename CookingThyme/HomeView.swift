//
//  HomeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var collection: RecipeCollectionVM
    @ObservedObject var timer = TimerHandler()
    
    var body: some View {
        NavigationView {
            TabView {
                RecipeCollectionView()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Recipe Book")
                    }
                
                ShoppingListView()
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("Shopping List")
                    }
                
                TimerView()
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Timer")
                    }
                
            }
            .font(.headline)
            .accentColor(mainColor())
            .navigationBarTitle("Cooking Thyme", displayMode: .inline)
            .background(NavigationBarConfigurator { nc in
                nc.navigationBar.barTintColor = mainUIColor()
                nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            })
        }
        .alert(isPresented: $timer.timerAlert) {
            Alert(title: Text("Timer"),
                  primaryButton: .default(Text("Stop")) {
                    timer.stop()
                  },
                  secondaryButton: .default(Text("Repeat")) {
                    timer.repeatTimer()
                  }
            )
        }
        .environmentObject(collection)
        .environmentObject(timer)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(collection: RecipeCollectionVM(collection: RecipeCollection(id: 0, name: "Becca")))
    }
}
