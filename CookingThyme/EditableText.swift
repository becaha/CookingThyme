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
    var onChanged: (String) -> Void
    var onDelete: () -> Void

    @State private var editableText: String = ""

    init(_ text: String, isEditing: Bool, onChanged: @escaping (String) -> Void, onDelete: @escaping () -> Void) {
        self.text = text
        self.isEditing = isEditing
        self.onChanged = onChanged
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack(alignment: .leading) {
            TextField(text, text: $editableText, onEditingChanged: { began in
                callOnChanged()
            })
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
        .deletable(isDeleting: isEditing, onDelete: onDelete)
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
