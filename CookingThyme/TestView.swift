//
//  TestView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/8/20.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack {
            Text("Title")
        
            Form {
                
                List {
                    Section(footer:
                        VStack(alignment: .center) {
                            Button(action: {
                              
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color(UIColor.tertiarySystemFill))
                                    
                                    Text("Add Ingredients to Shopping List")
        //                                            .foregroundColor(.black)
                                        .padding(.vertical)
                                }
                            }
                        }
                    ) {
                        Text("A")
                        Text("A")
                        Text("A")
                    }
                }
            }
        }
        .background(Color(UIColor.quaternarySystemFill))
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
