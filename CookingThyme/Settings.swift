//
//  Settings.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/13/21.
//

import SwiftUI
import Combine

struct Settings: View {
    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM
    
    @State var presentDeleteAlert = false
    @State var keyboardPresented = false

    @State var isEditing = false
    
    @State var email = ""
    @State var password = ""

    @State var deleteSuccessful = false
    
    @State var isReauthenticating = false
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Account Details").customFont(style: .subheadline)) {
                    HStack {
                        Text("Email")
                            .bold()
                        
                        Spacer()

                        Text("\(email)")
                            .customFont(style: .subheadline)
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
                                presentDeleteAlert = false
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
                                .customFont(style: .subheadline)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .formItem(padding: false)
                        }
                        .onTapGesture(count: 1, perform: {})
                    }
                    
                    HStack {
                        if presentDeleteAlert && !deleteSuccessful {
                            Button(action: {
                                user.clearErrors()
                                presentDeleteAlert = false
                            }) {
                                Text("Cancel")
                                    .foregroundColor(mainColor())
                                    .bold()
                            }
                            .onTapGesture(count: 1, perform: {})
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
                                HStack {
                                    Spacer()
                                    
                                    Text("Delete Account")
                                        .bold()
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .background(Color.white)
                            }
                            else if !deleteSuccessful && presentDeleteAlert {
                                Text("Delete Account")
                                    .bold()
                                    .foregroundColor(.red)
                            }
                            else if deleteSuccessful {
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
        .onReceive(Publishers.keyboardHeight) { height in
            keyboardPresented = height == 0 ? false : true
        }
        .gesture(keyboardPresented ?
                    TapGesture(count: 1).onEnded {
            withAnimation {
                unfocusEditable()
            }
        } : nil)
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
        .navigationBarColor(UIColor(navBarColor()))
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

