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
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var recipeSearchHandler: RecipeSearchHandler

    @AppStorage("log_status") var status = false

    
    var body: some View {
        TabView {
            
            RecipeSearch()
                .homeNavigationBar(settingsAction: settingsAction)
                .environmentObject(sheetNavigator)
                .environmentObject(recipeSearchHandler)
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Recipe Search")
            }
            
            NavigationView {
                if !user.isSignedIn {
                    SigninPromptView(message: "to start creating a recipe book.")
                        .navigationBarHidden(true)
                        .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
                        .environmentObject(sheetNavigator)
                }
                else if user.isSignedIn && user.collection == nil {
                    UIControls.Loading()
                }
                else if user.collection != nil {
                    RecipeCollectionView()
                        .environmentObject(user.collection!)
                        .environmentObject(recipeSearchHandler)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .homeNavigationBar(settingsAction: settingsAction)
            .tabItem {
                Image(systemName: "book.fill")
                Text("Recipe Book")
            }

            VStack {
                if !user.isSignedIn {
                    SigninPromptView(message: "to start creating a shopping list.")
                        .environmentObject(sheetNavigator)
                }
                else if user.isSignedIn && user.collection == nil {
                    UIControls.Loading()
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
        }
        .accentColor(mainColor())
        .sheet(isPresented: self.$sheetNavigator.showSheet) {
            self.sheetNavigator.navView()
                .environmentObject(sheetNavigator)
                .environmentObject(user)
        }
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
