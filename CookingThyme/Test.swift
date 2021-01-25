//
//  Test.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/22/21.
//

import SwiftUI

struct SearchBarTest: View {
    @Binding var search: String
    var isAutoSearch: Bool
    var onCommit: (String) -> Void
    
//    @State var search: String = ""
    
    var body: some View {
        let searchBinding = Binding<String>(get: {
                    self.search
                }, set: { updatedSearch in
                    self.search = updatedSearch
                    // do whatever you want here
                    onCommit(updatedSearch)
                })
        
        return HStack {
            TextField("Search", text: isAutoSearch ? searchBinding: $search, onCommit: {
                onCommit(search)
            })
            .font(Font.body.weight(.regular))
            .foregroundColor(.black)
            
            Button(action: {
                onCommit(search)
            }) {
                Image(systemName: "magnifyingglass")
                    .font(Font.body.weight(.regular))
                    .foregroundColor(searchFontColor())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct Test: View {
    var confirmAddIngredient = false
    @State var search = ""
    @State var commitCount = 0
    @State var commitedSearch = ""
    
    var body: some View {
        VStack {
            SearchBarTest(search: $search, isAutoSearch: true) { result in
                onCommit(result)
            }
            
            Button(action: {
                search = ""
            }) {
                Text("Clear \(commitCount)")
            }
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
