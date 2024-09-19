import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var text: NSAttributedString
    var font: UIFont = .systemFont(ofSize: 14)
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.allowsEditingTextAttributes = true
        
        // Remove the input accessory view (toolbar)
        textView.inputAccessoryView = nil
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.attributedText
        }
        
        // The formatting methods (toggleBold, toggleItalic, toggleUnderline) remain,
        // but they're not connected to any buttons now. They can be used if you decide
        // to add custom formatting options in the future.
    }
    
    enum TextStyle {
        case bold, italic, underline
    }
}

extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func withBold() -> UIFont {
        return withTrait(.traitBold)
    }
    
    func withoutBold() -> UIFont {
        return withoutTrait(.traitBold)
    }
    
    func withItalic() -> UIFont {
        return withTrait(.traitItalic)
    }
    
    func withoutItalic() -> UIFont {
        return withoutTrait(.traitItalic)
    }
    
    private func withTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        if let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(trait)) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return self
    }
    
    private func withoutTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        if let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.subtracting(trait)) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return self
    }
}