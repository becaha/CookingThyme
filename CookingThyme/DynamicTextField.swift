//
//  DynamicTextField.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI

struct DynamicTextField: View {
    @State private var text = "Hello"
    
    var body: some View {
        VStack {
            HStack {
                TextField("\(text)", text: $text)
                    .font(.system(size: 32.0, weight: .bold))
            }
            
            HStack {
                Button(action: {}) {
                    Text("Button")
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    func getFontSize(withWidth width: CGFloat, forText text: String) -> CGFloat {
        let oneLetter = "z"
        var fontSize = 32.0
//        let size = oneLetter.size(withAttributes:[.font: UIFont.systemFont(ofSize: fontSize)])
        
        
        return (width/CGFloat(text.count + 1 / 10))
    }
}

struct DynamicTextField_Previews: PreviewProvider {
    static var previews: some View {
        DynamicTextField()
    }
}
