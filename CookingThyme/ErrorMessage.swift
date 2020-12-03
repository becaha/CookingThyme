//
//  ErrorMessage.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI

struct ErrorMessage: View {
    var message: String
    @Binding var isError: Bool
    
    init(_ message: String, isError: Binding<Bool>) {
        self.message = message
        self._isError = isError
    }
    
    var body: some View {
        if isError {
            Button(action: {isError = false}) {
                Text("\(message)")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
    }
}

//struct ErrorMessage_Previews: PreviewProvider {
//    static var previews: some View {
//        ErrorMessage("error")
//    }
//}
