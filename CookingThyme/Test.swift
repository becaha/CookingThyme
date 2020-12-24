//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/18/20.
//

import SwiftUI

struct Test: View {
    let categories = ["All", "Sides", "Main Dishes", "All", "Sides", "Main", "All", "Sides", "Main"]
    let recipes = ["A", "B", "C"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("a")
                }
            }
            .navigationBarTitle(Text("Nav"))
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
