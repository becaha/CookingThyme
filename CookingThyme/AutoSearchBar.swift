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
            .customFont(style: .subheadline)
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

//struct AutoSearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        AutoSearchBar()
//    }
//}
