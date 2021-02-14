//
//  UserErrorsView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/13/21.
//

import SwiftUI

@ViewBuilder
func UserErrorsView(userErrors: [String]) -> some View {
    VStack {
        ForEach(userErrors, id: \.self) { message in
            HStack {
                Text("\(message)")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(0)

                Spacer()
            }
        }
    }
    .padding([.leading, .bottom])
}
