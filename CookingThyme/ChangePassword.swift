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
    
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    
    @State var success = false
    
    var body: some View {
        VStack {
            SecureField("Current Password", text: $oldPassword)
                .customFont(style: .subheadline)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
            
            SecureField("New Password", text: $newPassword)
                .customFont(style: .subheadline)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
            
            SecureField("Confirm Password", text: $confirmPassword)
                .customFont(style: .subheadline)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .formItem()
            
            UserErrorsView(userErrors: user.userErrors)

            Button(action: {
                user.changePassword(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
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
                    .foregroundColor(mainColor())
                    
                    Spacer()
                }
            }
            .formItem()
        }
        .formed()
        .loadableOverlay(isLoading: $user.isLoading)
        .onAppear {
            user.clearErrors()
            user.isLoading = nil
        }
        .onDisappear {
            withAnimation {
                user.clearErrors()
                user.isLoading = nil
            }
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
        .navigationBarTitle("Change Password")
    }
    
    func reset() {
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}
