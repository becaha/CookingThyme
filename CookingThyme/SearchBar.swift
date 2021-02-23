//
//  SearchBar.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/10/20.
//

import SwiftUI

struct SearchBar: View {
    var isAutoSearch: Bool
    var onCommit: (String) -> Void
    
    @State var search: String = ""
    
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
            .customFont(style: .subheadline)
            .foregroundColor(searchFontColor())
            
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
