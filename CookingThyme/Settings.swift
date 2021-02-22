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
    
    @State var email = ""
    @State var password = ""

    @State var deleteSuccessful = false
    
    @State var isReauthenticating = false
    
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
                
                Section(footer: UserErrorsView(userErrors: user.userErrors, padding: false)) {
                    if presentDeleteAlert {
                        HStack {
                            SecureField("Confirm Password", text: $password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .formItem(padding: false)
                        }
                    }
                    
                    HStack {
                        if presentDeleteAlert && !deleteSuccessful {
                            Button(action: {
                                presentDeleteAlert = false
                            }) {
                                Text("Cancel")
                                    .foregroundColor(mainColor())
                                    .bold()
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            withAnimation {
                                if !presentDeleteAlert {
                                    presentDeleteAlert = true
                                }
                                else {
                                    user.delete(password: password)
                                }
                            }
                        }) {
                            if !deleteSuccessful && !presentDeleteAlert {
                                Spacer()
                                
                                Text("Delete Account")
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            else if !deleteSuccessful && presentDeleteAlert {
                                Text("Delete Account")
                                    .bold()
                                    .foregroundColor(.red)
                            }
                            else {
                                Spacer()
                                
                                Text("Successfully Deleted Account")
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())

        }
        .loadable(isLoading: $user.isLoading)
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
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                unfocusEditable()
            }
        )
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
        .navigationBarColor(offWhiteUIColor())
    }
    
    func onLoadingComplete() {
        withAnimation {
            if user.userErrors.count == 0 && !user.isReauthenticating {
                withAnimation {
                    if presentDeleteAlert {
                        deleteSuccessful = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            sheetNavigator.showSheet = false
                        }
                    }
                    else {
                        sheetNavigator.showSheet = false
                    }
                }
            }
            
        }
    }
}
