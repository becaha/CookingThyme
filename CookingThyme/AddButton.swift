//
//  AddButton.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/25/20.
//

import SwiftUI

struct AddButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Add")
                .foregroundColor(.black)
        }
    }
}

//struct AddButton_Previews: PreviewProvider {
//    static var previews: some View {
//        AddButton()
//    }
//}
