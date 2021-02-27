//
//  SelectableText.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/1/21.
//

import SwiftUI
 
struct EditableTextView: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextViewDelegate {

        var text: Binding<String>
        var didBecomeFirstResponder = false

        init(_ text: Binding<String>) {
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
    }
 
    @Binding var textBinding: String
    var isFirstResponder: Bool = false
    var textStyle: UIFont.TextStyle = UIFont.TextStyle.subheadline
    var textAlignment = NSTextAlignment.left
    var isEditable = true
    var backgroundColor: UIColor = UIColor.clear
    
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont(name: mainFont(), size: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
        textView.backgroundColor = backgroundColor
        textView.textAlignment = textAlignment
        textView.delegate = context.coordinator
        textView.isEditable = isEditable

        return textView
    }

    func makeCoordinator() -> EditableTextView.Coordinator {
        return Coordinator($textBinding)
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = textBinding

        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
