//
//  EditableText.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 11/24/20.
//

import SwiftUI

//TODO: have auto capitalization an option
struct EditableText: View {
    var text: String = ""
    var isEditing: Bool
    var onChanged: (String) -> Void
    var onDelete: () -> Void
    var isDeletable: Bool
    var autocapitalization: UITextAutocapitalizationType

    @State private var editableText: String = ""
    
    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void) {
        self.text = text
        self.isEditing = isEditing
        self.onChanged = onChanged
        self.onDelete = {}
        self.isDeletable = false
        self.autocapitalization = .none
    }
    
//    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void, autocapitalization: UITextAutocapitalizationType?) {
//        self.text = text
//        self.isEditing = isEditing
//        self.onChanged = onChanged
//        self.onDelete = {}
//        self.isDeletable = false
//        if let autocap = autocapitalization {
//            self.autocapitalization = autocap
//        }
//        else {
//            self.autocapitalization = .none
//        }
//    }
    
    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void, autocapitalization: UITextAutocapitalizationType) {
        self.text = text
        self.isEditing = isEditing
        self.onChanged = onChanged
        self.onDelete = {}
        self.isDeletable = false
        self.autocapitalization = autocapitalization
    }
    
    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.text = text
        self.isEditing = isEditing
        self.onChanged = onChanged
        self.onDelete = onDelete
        self.isDeletable = true
        self.autocapitalization = .none
    }

    var body: some View {
        ZStack(alignment: .leading) {
            TextField(text, text: $editableText, onEditingChanged: { began in
                callOnChanged()
            })
            .autocapitalization(autocapitalization)
            .opacity(isEditing ? 1 : 0)
            .disabled(!isEditing)

            if !isEditing {
                Text(text)
                    .opacity(isEditing ? 0 : 1)
                    .onAppear {
                        // any time we move from editable to non-editable
                        // we want to report any changes that happened to the text
                        // while were editable
                        // (i.e. we never "abandon" changes)
                        callOnChanged()
                    }
            }
        }
        .deletable(isDeleting: isEditing && isDeletable, onDelete: onDelete)
        .onAppear {
            editableText = text
        }
    }

    func callOnChanged() {
        if editableText != text {
            onChanged(editableText)
        }
    }
}
