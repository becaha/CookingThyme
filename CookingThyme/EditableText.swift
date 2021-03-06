//
//  EditableText.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

struct EditableText: View {
    var text: String = ""
    var isEditing: Bool
    var isSelected: Bool
    var onChanged: (String) -> Void
    var onDelete: () -> Void
    var isDeletable: Bool
    var autocapitalization: UITextAutocapitalizationType

    @State private var editableText: String = ""
    
    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void) {
        self.text = text
        self.isEditing = isEditing
        self.isSelected = false
        self.onChanged = onChanged
        self.onDelete = {}
        self.isDeletable = false
        self.autocapitalization = .none
    }
    
    init(_ text: String, isEditing: Bool, isSelected: Bool, onChanged: @escaping (String) -> Void) {
        self.text = text
        self.isEditing = isEditing
        self.isSelected = isSelected
        self.onChanged = onChanged
        self.onDelete = {}
        self.isDeletable = false
        self.autocapitalization = .none
    }
    
    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void, autocapitalization: UITextAutocapitalizationType) {
        self.text = text
        self.isEditing = isEditing
        self.isSelected = false
        self.onChanged = onChanged
        self.onDelete = {}
        self.isDeletable = false
        self.autocapitalization = autocapitalization
    }
    
    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.text = text
        self.isEditing = isEditing
        self.isSelected = false
        self.onChanged = onChanged
        self.onDelete = onDelete
        self.isDeletable = true
        self.autocapitalization = .none
    }

    var body: some View {
        ZStack {
            if !isEditing {
                Text(text)
                    .customFont(style: .subheadline, weight: isSelected ? .bold : .regular)
                    .opacity(isEditing ? 0 : 1)
                    .onAppear {
                        callOnChanged(false)
                    }
            }
            else {
                TextField(text, text: $editableText, onEditingChanged: { begin in
                    callOnChanged(begin)
                })
                .customFont(style: .subheadline)
                .autocapitalization(autocapitalization)
                .opacity(isEditing ? 1 : 0)
            }
        }
        .deletable(isDeleting: isEditing && isDeletable, onDelete: onDelete)
        .onAppear {
            editableText = text
        }
    }

    func callOnChanged(_ begin: Bool) {
        if editableText != text {
            onChanged(editableText)
        }
    }
}

struct EditableText_Previews: PreviewProvider {
    static var previews: some View {
        EditableText("hi", isEditing: false, onChanged: { string in
            
        })
    }
}
