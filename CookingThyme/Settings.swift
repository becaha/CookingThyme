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
    
    @Binding var isPresented: Bool

    @State var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if isPresented && !user.isSignedIn {
                        Section {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        user.signinPresented = true
                                        isPresented = true
                                    }
                                }) {
                                    Text("Sign In")
                                        .bold()
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    else if isPresented {
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
                                        isPresented = false
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
                                    isPresented = false
                                }) {
                                    Text("Delete Account")
                                        .bold()
                                        .foregroundColor(.red)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    isPresented = false
                }) {
                    Text("Done")
                }
    //            UIControls.EditButton(
    //                action: {
    //                    isEditing.toggle()
    //                },
    //                isEditing: isEditing)
            )
        }
    }
}

//struct Settings_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            Settings()
//        }
//    }
//}
