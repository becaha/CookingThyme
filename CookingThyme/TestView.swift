//
//  TestView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .center) {
                    VStack {
                    Image(systemName: "plus")
                        .padding(.bottom, 5)
                    
                    Text("Add Photo")
                        .font(.subheadline)
                        .padding(.top, 0)
                    }
                    .frame(width: geometry.size.width/2)
                    .border(Color.black, width: 3.0, isDashed: true)
                }
                .padding()
//                .frame(width: geometry.size.width)
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
