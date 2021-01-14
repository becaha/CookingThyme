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
                    if !user.isSignedIn {
                        SigninPromptView(message: "to start creating a recipe book.")
                    }
                    else if user.collection != nil {
                        RecipeCollectionView()
                            .environmentObject(user.collection!)
                    }
                }
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipe Book")
                }
                
                Group {
                    if !user.isSignedIn {
                        SigninPromptView(message: "to start creating a shopping list.")
                    }
                    else if user.collection != nil {
                        ShoppingListView()
                            .environmentObject(user.collection!)
                    }
                }
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
            .navigationBarItems(trailing:
                Button(action: {
                    user.sheetPresented = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.black)
                }
            )
            .background(NavigationBarConfigurator { nc in
                nc.navigationBar.barTintColor = mainUIColor()
                nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
            })
        }
        .sheet(isPresented: $user.sheetPresented, onDismiss: {
            user.signinPresented = false
        }) {
            HomeSheet(isPresented: $user.sheetPresented)
                .environmentObject(user)
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
