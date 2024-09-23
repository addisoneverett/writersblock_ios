import SwiftUI

extension Font {
    static func typewriter(size: CGFloat) -> Font {
        return Font.custom("AmericanTypewriter", size: size)
            .fallback(.system(size: size))
    }
    
    static var typewriterBody: Font {
        return typewriter(size: 10) // Changed from 12 to 10
    }
    
    static var typewriterTitle: Font {
        return typewriter(size: 28)
    }
    
    static var typewriterHeadline: Font {
        return typewriter(size: 18)
    }
    
    // Add more as needed
}

extension Font {
    func fallback(_ font: Font) -> Font {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            .withDesign(.serif)?
            .withSymbolicTraits(.traitMonoSpace) ?? .init()
        let uiFont = UIFont(descriptor: descriptor, size: descriptor.pointSize)
        return Font(uiFont)
    }
}