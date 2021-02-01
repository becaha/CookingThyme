//
//  TextView.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 2/1/21.
//

import SwiftUI
 
struct TextView: UIViewRepresentable {
 
    @Binding var text: String
    var isEditable: Bool
    var textStyle: UIFont.TextStyle
 
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
 
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.delegate = context.coordinator
        textView.isEditable = isEditable
//        textView.frame.size.height = textView.contentSize.height

        return textView
    }
 
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
//        let contentSize = uiView.contentSize
//        uiView.frame.size.height = uiView.contentSize.height

    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }
     
    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
     
        init(_ text: Binding<String>) {
            self.text = text
        }
     
        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
    }
}

//struct TextView_Previews: PreviewProvider {
//    static var previews: some View {
//        TextView()
//    }
//}
