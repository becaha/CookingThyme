//
//  HomeView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/7/20.
//

import SwiftUI
import Firebase

struct HomeView: View {
    // the view knows when sheet is dismissed
    @Environment(\.presentationMode) var presentation
    
    @EnvironmentObject var user: UserVM
    @EnvironmentObject var timer: TimerHandler
    @EnvironmentObject var sheetNavigator: SheetNavigator
            
    @AppStorage("log_status") var status = false

    
    var body: some View {
        TabView {
            NavigationView {
                if !user.isSignedIn {
                    SigninPromptView(message: "to start creating a recipe book.")
                        .environmentObject(sheetNavigator)
                }
                else if user.collection != nil {
                    RecipeCollectionView()
                        .environmentObject(user.collection!)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .homeNavigationBar(settingsAction: settingsAction)
            .tabItem {
                Image(systemName: "book.fill")
                Text("Recipe Book")
            }
            
            RecipeSearch()
            .homeNavigationBar(settingsAction: settingsAction)
            .environmentObject(sheetNavigator)
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Recipe Search")
            }

            VStack {
                if !user.isSignedIn {
                    SigninPromptView(message: "to start creating a shopping list.")
                        .environmentObject(sheetNavigator)
                }
                else if user.collection != nil {
                    ShoppingListView()
                        .environmentObject(user.collection!)
                }
            }
            .homeNavigationBar(settingsAction: settingsAction)
            .tabItem {
                Image(systemName: "cart.fill")
                Text("Shopping List")
            }

            TimerView()
            .homeNavigationBar(settingsAction: settingsAction)
            .tabItem {
                Image(systemName: "timer")
                Text("Timer")
            }
            
        }
        .accentColor(mainColor())
        .sheet(isPresented: self.$sheetNavigator.showSheet) {
            self.sheetNavigator.navView()
                .environmentObject(sheetNavigator)
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
    
    func settingsAction() {
        if user.isSignedIn {
            self.sheetNavigator.sheetDestination = .settings
        } else {
            self.sheetNavigator.sheetDestination = .signin
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
