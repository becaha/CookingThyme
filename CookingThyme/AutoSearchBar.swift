//
//  AutoSearchBar.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 1/25/21.
//

import SwiftUI

struct AutoSearchBar: View {
    @Binding var search: String
    var onCommit: (String) -> Void
    
    @State var isFocused = false
    
    var body: some View {
        let searchBinding = Binding<String>(get: {
                    self.search
                }, set: { updatedSearch in
                    self.search = updatedSearch
                    // do whatever you want here
                    onCommit(updatedSearch)
                })
        
        return
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(Font.body.weight(.regular))
                    .foregroundColor(searchFontColor())
                
                TextField("Search...", text: searchBinding, onCommit: {
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

//struct AutoSearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        AutoSearchBar()
//    }
//}
