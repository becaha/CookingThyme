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
    var isCentered: Bool
    
    init(_ message: String, isError: Binding<Bool>) {
        self.message = message
        self._isError = isError
        self.isCentered = false
    }
    
    init(_ message: String, isError: Binding<Bool>, isCentered: Bool) {
        self.message = message
        self._isError = isError
        self.isCentered = isCentered
    }
    
    var body: some View {
        if isError {
            HStack {
                if isCentered {
                    Spacer()
                }
                
                Button(action: {isError = false}) {
                    Text("\(message)")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Spacer()
            }
        }
    }
}
