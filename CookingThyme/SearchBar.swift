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
