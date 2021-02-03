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
//    var text: String
//    var textStyle: UIFont.TextStyle
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textView.delegate = context.coordinator
        textView.isEditable = true

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

func attributedString(for string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let range = NSMakeRange(0, (string as NSString).length)
        attributedString.addAttribute(.font, value: Font.system(size: 24, weight: .regular), range: range)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        return attributedString
}

extension NSAttributedString {
    func height(containerWidth: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        return ceil(rect.size.height)
    }
}


struct TestView: View {
    
    @State private var selectableText = "textview"
    var textStyle = UIFont.TextStyle.body
    
    @State var text = "text that is too large to fit on the screen because it is tooooooooooooooooooo large"
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("Niice ")
                    .formSectionItem()
                
                ForEach((1...11).reversed(), id: \.self) { _ in
                    HStack {
//                        EditableTextView(textBinding: $text)
                    }
    //                .formSectionItem()
                }
                
            }
            .formSection()
            .background(formBackgroundColor())
        }
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
