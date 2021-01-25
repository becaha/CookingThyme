//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct Test: View {
    var confirmAddIngredient = false
    @State var search = ""
    @State var commitCount = 0
    @State var commitedSearch = ""
    
    var body: some View {
        let searchBinding = Binding<String>(get: {
                    self.search
                }, set: { updatedSearch in
                    self.search = updatedSearch
                    // do whatever you want here
                    onCommit(updatedSearch)
                })
        
        return HStack {
            TextField("Search", text: searchBinding, onCommit: {
                onCommit(search)
            })
            
            Text("\(commitCount)")
            
            Text("\(commitedSearch)")

        }
    }
        
        func onCommit(_ search: String) {
            commitCount += 1
            commitedSearch = search
        }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
