//
//  DirectionTest.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/21/21.
//

import SwiftUI

struct DirectionTest: View {
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                NavigationView {
                    VStack {
                        HStack {
                            Text("testie")
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .background(formBackgroundColor())
                    .navigationBarTitle("Title", displayMode: .inline)
                }
                
                Spacer()
                
                Text("hello")
                
            }
            .ignoresSafeArea()
            .background(formBackgroundColor().edgesIgnoringSafeArea(.all))
        }
    }
}

struct DirectionTest_Previews: PreviewProvider {
    static var previews: some View {
        DirectionTest()
    }
}
