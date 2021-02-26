//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI
import Combine

struct Test: View {
    @State var test = ""
    
    var body: some View {
        VStack {
            Text("\(test)")
            
            TextField("Hello, World!", text: $test)
                .simultaneousGesture(TapGesture(count: 1).onEnded {
//                    test += "child"
//                    print("Text tapped")
                })
            
            Spacer()
        }
        .gesture(TapGesture(count: 1).onEnded {
            test += "parent"
            print("VStack tapped")
        })
    }
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
