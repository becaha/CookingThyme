//
//  Settings.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/13/21.
//

import SwiftUI

// TODO: edit account settings like email
struct Settings: View {
    @EnvironmentObject var user: UserVM
    
    @State var presentDeleteAlert = false

    @State var isEditing = false
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Account Details")) {
                    HStack {
                        Text("Username")
                            .bold()

                        Spacer()

                        Text("\(user.username)")
                            .fontWeight(.regular)
                    }
                    
                    HStack {
                        Text("Email")
                            .bold()
                        
                        Spacer()

                        Text("\(user.email)")
                            .fontWeight(.regular)
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
                                user.sheetPresented = false
                                user.signout()
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
                            // TODO
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
                        user.sheetPresented = false
                        user.delete()
                    }
                  },
                  secondaryButton: .cancel()
            )
        }
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
//        .navigationBarItems(trailing:
//            UIControls.EditButton(
//                action: {
//                    isEditing.toggle()
//                },
//                isEditing: isEditing)
//        )
    }
}

//struct Settings_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            Settings()
//        }
//    }
//}
