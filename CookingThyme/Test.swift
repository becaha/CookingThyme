//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/21/21.
//

import SwiftUI

struct Test: View {
    @State var isPresented = true
    @State var newDirection: String = ""
    
    var directions = ["mix", "drink"]
    
    var body: some View {
        Form {
            Section(header: Text("Directions")) {
                List {
                    HStack(alignment: .top, spacing: 20) {
                        // edit
                        Group {
                            Text("\(20)")
                            
                            TextEditor(text: $newDirection)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.vertical, -7)
                            
//                            TextField("\(directions[0])", text: $newDirection)

                        }
                        .padding(.vertical)
                    }
                    
                    HStack(alignment: .top, spacing: 20) {
                        // edit
                        Group {
                            Text("\(21)")
                            
                            TextEditor(text: $newDirection)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.vertical, -7)

                        }
                        .padding(.vertical)
                    }
                }
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
