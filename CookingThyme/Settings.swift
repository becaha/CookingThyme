//
//  Settings.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/13/21.
//

import SwiftUI

// TODO: edit account settings like email
struct Settings: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    
    @State var presentDeleteAlert = false

    @State var isEditing = false
    
    @State var username = ""
    @State var email = ""
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Account Details")) {
                    HStack {
                        Text("Username")
                            .bold()

                        Spacer()

                        Text("\(username)")
                            .fontWeight(.regular)
                            .onAppear {
                                username = user.username
                            }
                    }
                    
                    HStack {
                        Text("Email")
                            .bold()
                        
                        Spacer()

                        Text("\(email)")
                            .fontWeight(.regular)
                            .onAppear {
                                email = user.email
                            }
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            // TODO
                        }) {
                            Text("Change Password")
                                .bold()
                        }
                        
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                user.signout()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    sheetNavigator.showSheet = false
                                }
                            }
                        }) {
                            Text("Sign Out")
                                .bold()
                        }
                        
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            presentDeleteAlert = true
                        }) {
                            Text("Delete Account")
                                .bold()
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())

        }
        .alert(isPresented: $presentDeleteAlert) {
            Alert(title: Text("Confirm Delete Account"),
                  primaryButton: .default(Text("Delete")) {
                    withAnimation {
                        user.delete()
                        sheetNavigator.showSheet = false
                    }
                  },
                  secondaryButton: .cancel()
            )
        }
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
    }
}

//struct Settings_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            Settings()
//        }
//    }
//}
