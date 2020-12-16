//
//  UIControls.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/17/20.
//

import SwiftUI

struct UIControls {
    
    @ViewBuilder
    static func Loading() -> some View {
        HStack {
            Spacer()
            
            ProgressView()
                .frame(alignment: .center)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    static func EditButton(action: @escaping () -> Void, isEditing: Bool) -> some View {
        Button(action: action) {
            Text(isEditing ? "Done" : "Edit")
                .foregroundColor(.black)
        }
    }
    
    @ViewBuilder
    static func AddButton(action: @escaping () -> Void, isPlain: Bool = true) -> some View {
        if isPlain {
            Button(action: action) {
                Image(systemName: "plus")
                    .frame(width: 20, height: 20, alignment: .center)
            }
            .buttonStyle(PlainButtonStyle())
        }
        else {
            Button(action: action) {
                Image(systemName: "plus")
                    .frame(width: 20, height: 20, alignment: .center)
            }
        }
    }
}
