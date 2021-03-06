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
            if textView.textColor == UIColor(placeholderFontColor()) {
                textView.textColor =  UIColor(formItemFont())

            }
            if textView.text == placeholderText {
                textView.text = nil
            }
        }
        
        // on user end, set back to placeholder
        func textViewDidEndEditing(_ textView: UITextView) {
            textView.textColor = UIColor(placeholderFontColor())
            textView.text = placeholderText
        }

    }
    
    var placeholderText: String
    @Binding var textBinding: String
    var isFirstResponder: Bool = false
    var textStyle: UIFont.TextStyle = UIFont.TextStyle.subheadline
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont(name: mainFont(), size: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.backgroundColor = UIColor.clear
        
        textView.text = placeholderText
        textView.textColor = UIColor(placeholderFontColor())

        return textView
    }

    func makeCoordinator() -> PlaceholderTextView.Coordinator {
        return Coordinator(placeholderText, text: $textBinding)
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != placeholderText  {
            uiView.text = textBinding
        }

        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
