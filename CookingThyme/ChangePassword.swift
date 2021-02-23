//
//  ChangePassword.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/26/21.
//

import SwiftUI
import Combine

struct ChangePassword: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM

    var onSaveChanges: (String, String, String) -> Void
    
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    
    @State var success = false
    
    @State var keyboardPresented = false
    
    var body: some View {
        VStack {
            SecureField("Current Password", text: $oldPassword)
                .customFont(style: .subheadline)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
                .onTapGesture(count: 1, perform: {})
            
            SecureField("New Password", text: $newPassword)
                .customFont(style: .subheadline)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
                .onTapGesture(count: 1, perform: {})
            
            SecureField("Confirm Password", text: $confirmPassword)
                .customFont(style: .subheadline)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
                .onTapGesture(count: 1, perform: {})
            
            UserErrorsView(userErrors: user.userErrors)

            Button(action: {
                onSaveChanges(oldPassword, newPassword, confirmPassword)
            }) {
                HStack {
                    Spacer()
                    
                    Group {
                        if !success {
                            Text("Save Changes")
                                .bold()
                        }
                        else {
                            Text("Password Changed Successfully")
                                .bold()
                        }
                    }
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            .onTapGesture(count: 1, perform: {})
            .formItem(backgroundColor: mainColor())
        }
        .formed()
        .loadable(isLoading: $user.isLoading)
        .onAppear {
            user.clearErrors()
            user.isLoading = nil
        }
        .onChange(of: user.isLoading, perform: { isLoading in
            if let isLoading = isLoading, !isLoading {
                user.isLoading = nil
                if user.userErrors.count == 0 && !user.isReauthenticating {
                    withAnimation {
                        success = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.presentationMode.wrappedValue.dismiss()
                            reset()
                        }
                    }
                }
            }
        })
        .onReceive(Publishers.keyboardHeight) { height in
            keyboardPresented = height == 0 ? false : true
        }
        .gesture(keyboardPresented ?
                    TapGesture(count: 1).onEnded {
            withAnimation {
                unfocusEditable()
            }
        } : nil)
        .navigationBarTitle("Change Password")
    }
    
    func reset() {
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}
