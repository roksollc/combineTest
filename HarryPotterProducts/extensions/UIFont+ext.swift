//
//  UIFont+ext.swift
//  HarryPotterProducts
//

import UIKit

extension UIFont {
    var bolded: UIFont {
        withTraits(traits: .traitBold)
    }
    var semibolded: UIFont {
        withWeight(.semibold)
    }
    var italicized: UIFont {
        withTraits(traits: .traitItalic)
    }
    var boldItalicized: UIFont {
        withTraits(traits: [.traitBold, .traitItalic])
    }

    // --

    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        // size 0 means keep the size as it is
        return UIFont(descriptor: descriptor!, size: 0)
    }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
