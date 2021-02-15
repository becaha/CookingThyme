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
                        Text("Email")
                            .bold()
                        
                        Spacer()

                        Text("\(email)")
                            .fontWeight(.regular)
                            .onAppear {
                                email = user.email
                            }
                    }
                    
                    NavigationLink(destination:
                            ChangePassword(
                                  onSaveChanges: { oldPassword, newPassword, confirmPassword in
                                    user.changePassword(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
                                    return user.userErrors
                              })
                    ) {
                        Text("Change Password")
                            .bold()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
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
                    }
                  },
                  secondaryButton: .cancel()
            )
        }
        .onAppear {
            user.clearErrors()
            user.isLoading = nil
        }
        .onChange(of: user.isLoading, perform: { isLoading in
            if let isLoading = isLoading, !isLoading {
                user.isLoading = nil
                onLoadingComplete()
            }
        })
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
        .navigationBarColor(offWhiteUIColor())
    }
    
    func onLoadingComplete() {
        withAnimation {
            if user.userErrors.count == 0 {
                sheetNavigator.showSheet = false
            }
        }
    }
}
