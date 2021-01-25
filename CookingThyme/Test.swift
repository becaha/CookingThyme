//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    var confirmAddIngredient = false
    @State var testA = ""
    @State var testB = ""
    @State var a = 0
    @State var aCommit = 0
    @State var b = 0
    @State var bCommit = 0

    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                TextField("a", text: $testA, onEditingChanged: { begin in
                    if begin {
                        a += 1
                    }
                    else {
                        aCommit += 1
                    }
                }, onCommit: {
                    aCommit += 1
                })
                
                TextField("b", text: $testB, onEditingChanged: { begin in
                    b += 1
                }, onCommit: {
                    bCommit += 1
                })
                
                Button(action: {
                    bCommit = 5
                }) {
                    Text("click")
                }
                
                Text("\(a)")
                
                Text("\(aCommit)")

                Text("\(b)")
                
                Text("\(bCommit)")

            }
            .padding(.horizontal)
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
