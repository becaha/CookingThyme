//
//  PlaceholderTextView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/2/21.
//

import SwiftUI
 
struct PlaceholderTextView: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextViewDelegate {

        var placeholderText: String
        var text: Binding<String>
        var didBecomeFirstResponder = false

        init(_ placeholderText: String, text: Binding<String>) {
            self.placeholderText = placeholderText
            self.text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.textColor = UIColor.black
            }
            if textView.text == placeholderText {
                textView.text = nil
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            textView.textColor = UIColor.lightGray
        }

    }
    
    var placeholderText: String
    @Binding var textBinding: String
    var isFirstResponder: Bool = false
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textView.delegate = context.coordinator
        textView.isEditable = true
        
//        textView.text = placeholderText
//        textView.textColor = UIColor.lightGray

        return textView
    }

    func makeCoordinator() -> PlaceholderTextView.Coordinator {
        return Coordinator(placeholderText, text: $textBinding)
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if textBinding != "" {
            uiView.text = textBinding
        }
        else {
            uiView.text = placeholderText
            uiView.textColor = UIColor.lightGray
        }

        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
