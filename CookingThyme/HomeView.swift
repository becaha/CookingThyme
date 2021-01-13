//
//  HomeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var user: UserVM
    @ObservedObject var timer = TimerHandler()
        
    var body: some View {
        NavigationView {
            TabView {
                RecipeSearch()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Recipe Search")
                    }
                
                Group {
                    if user.collection == nil {
                        LoginPromptView(message: "to start creating a recipe book.")
                    }
                    else {
                        RecipeCollectionView()
                    }
                }
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipe Book")
                }
                .environmentObject(user.collection!)
                
                Group {
                    if user.collection == nil {
                        LoginPromptView(message: "to start creating a shopping list.")
                    }
                    else {
                        ShoppingListView()
                    }
                }
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shopping List")
                }
                .environmentObject(user.collection!)
                
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
        .sheet(isPresented: $user.loginPresented) {
            LoginView()
        }
        .alert(isPresented: $timer.timerAlert) {
            Alert(title: Text("Timer"),
                  primaryButton: .default(Text("Stop")) {
                    withAnimation {
                        timer.stop()
                    }
                  },
                  secondaryButton: .default(Text("Repeat")) {
                    withAnimation {
                        timer.repeatTimer()
                    }
                  }
            )
        }
        .environmentObject(timer)
        .environmentObject(user)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
