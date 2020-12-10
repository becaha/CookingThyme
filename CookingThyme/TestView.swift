//
//  TestView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

struct TestView: View {
    @State var isLoading = true
    
    var body: some View {
        VStack {
            HStack {
                Text("hi")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            
                Form {
                    if isLoading {
//                        VStack {
                            UIControls.Loading()
//                        }
//                        .frame(height: 500)
                    }
                    else {
                    Section {}
                    }
                }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
