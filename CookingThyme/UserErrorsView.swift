//
//  UserErrorsView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/13/21.
//

import SwiftUI

@ViewBuilder
func UserErrorsView(userErrors: [String], padding: Bool = true) -> some View {
    VStack {
        ForEach(userErrors, id: \.self) { message in
            HStack {
                Text("\(message)")
                    .customFont(style: .footnote)
                    .foregroundColor(.red)
                    .padding(0)

                Spacer()
            }
        }
    }
    .padding(padding ? [.leading, .bottom] : [])
}
