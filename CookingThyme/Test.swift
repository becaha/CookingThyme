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
//        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack {
//                    Button("Scroll to 50") {
//                        withAnimation {
//                            proxy.scrollTo(50, anchor: .center)
//                        }
//                    }

                    VStack(spacing: 0) {
                        ForEach(0..<50) { i in
                            TextField("move me", text: $test)
//                                .id(i)
//                                .frame(height: 32)
                        }
                    }

                    
//                    Button("Top 20") {
//                        withAnimation {
//                            proxy.scrollTo(20, anchor: .center)
//                        }
//                    }
                }
                .background(Color.blue)
            }
//        }
    }
        
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
