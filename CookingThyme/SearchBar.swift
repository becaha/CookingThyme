//
//  SearchBar.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import SwiftUI

struct SearchBar: View {
    var onCommit: (String) -> Void
    @State var search: String = ""
    
    var body: some View {
        HStack {
            TextField("Search", text: $search, onCommit: {
                onCommit(search)
            })
            
            Button(action: {
                onCommit(search)
            }) {
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar()
//    }
//}
