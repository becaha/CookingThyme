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
    @State var isFocused = false
    
    var body: some View {
        
        return
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(Font.body.weight(.regular))
                    .foregroundColor(searchFontColor())
                
                TextField("Search...", text: $search, onCommit: {
                    onCommit(search)
                    withAnimation {
                        isFocused = false
                    }
                })
                .customFont(style: .subheadline)
                .foregroundColor(formItemFont())
                .onTapGesture {
                    withAnimation {
                        isFocused = true
                    }
                }
                
                if isFocused {
                    Button(action: {
                        search = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(Font.body.weight(.regular))
                            .foregroundColor(searchFontColor())
                    }
                }
            }
            .formItem(isSearchBar: true)
    }
}
