//
//  ChangePassword.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/26/21.
//

import SwiftUI

struct ChangePassword: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var sheetNavigator: SheetNavigator
    @EnvironmentObject var user: UserVM

    var onSaveChanges: (String, String, String) -> Void
    
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    
    @State var success = false
    
    var body: some View {
        VStack {
            SecureField("Current Password", text: $oldPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
            
            SecureField("New Password", text: $newPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
            
            SecureField("Confirm Password", text: $confirmPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
            
            UserErrorsView(userErrors: user.userErrors)

            Button(action: {
                onSaveChanges(oldPassword, newPassword, confirmPassword)
            }) {
                HStack {
                    Spacer()
                    
                    Group {
                        if !success {
                            Text("Save Changes")
                        }
                        else {
                            Text("Password Changed Successfully")
                        }
                    }
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            .formItem(backgroundColor: mainColor())
        }
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
        .formed()
        .navigationBarTitle("Change Password")
    }
    
    func reset() {
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}
