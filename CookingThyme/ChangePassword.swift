//
//  ChangePassword.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/26/21.
//

import SwiftUI

struct ChangePassword: View {
    var onSaveChanges: (String, String, String) -> String
    
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    @State var changeErrorMessage: String = ""
    
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
            
            HStack {
                Text("\(changeErrorMessage)")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(0)
                
                Spacer()
            }
            .padding(.leading)
            .padding(.bottom, 10)

            Button(action: {
                changeErrorMessage = onSaveChanges(oldPassword, newPassword, confirmPassword)
                if changeErrorMessage == "" {
                    withAnimation {
                        success = true
                        reset()
                    }
                }
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
        .formed()
        .navigationBarTitle("Change Password")
    }
    
    func reset() {
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}

//struct ChangeSetting_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeSetting()
//    }
//}
