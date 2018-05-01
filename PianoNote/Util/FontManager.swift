//
//  FontManager.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation
import UIKit

class FontManager {
    static let shared = FontManager()

    private init() {}

    private var customFont = UIFont.systemFont(ofSize: 17)
    private var customBoldFont = UIFont.boldSystemFont(ofSize: 17)

    private func getFontDescriptor() -> UIFontDescriptor {
        return customFont.fontDescriptor
    }

    private func getBoldFontDescriptor() -> UIFontDescriptor {
        return customBoldFont.fontDescriptor
    }

    private func getItalicFontDescriptor() -> UIFontDescriptor {
        let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(Float(11*Double.pi/180.0))), d: 1, tx: 0, ty: 0)
        return customFont.fontDescriptor.withMatrix(matrix)
    }

    private func getBoldItalicFontDescriptor() -> UIFontDescriptor {
        let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(Float(11*Double.pi/180.0))), d: 1, tx: 0, ty: 0)
        return customBoldFont.fontDescriptor.withMatrix(matrix)
    }

    private func getDescriptor(from traits: FontTraits) -> UIFontDescriptor {
        if traits.contains(.bold) && traits.contains(.italic){
            return getBoldItalicFontDescriptor()
        } else if traits.contains(.bold) {
            return getBoldFontDescriptor()
        } else if traits.contains(.italic) {
            return getItalicFontDescriptor()
        } else {
            return getFontDescriptor()
        }
    }
    
    private func getOffsetFromSize() -> CGFloat {
        switch PianoNoteSizeInspector.shared.get() {
        case .verySmall: return -8.0
        case .small: return -4.0
        case .normal: return 0.0
        case .large: return 4.0
        case .veryLarge: return 8.0
        }
    }

    private func getSize(from category: FontSizeCategory) -> CGFloat{
        let offset = getOffsetFromSize()
        switch category {
            case .title1: return 24.0 + offset
            case .title2: return 22.0 + offset
            case .title3: return 20.0 + offset
            case .body: return 17.0 + offset
        }
    }

    func font(for attribute: PianoFontAttribute) -> UIFont {
        let descriptor = getDescriptor(from: attribute.traits)
        let size = getSize(from: attribute.sizeCategory)

        return UIFont(descriptor: descriptor, size: size)
    }

    func fontAttribute(for font: UIFont) -> PianoFontAttribute {
        var traits: FontTraits = []
        
        if !font.fontDescriptor.matrix.c.isZero {
            traits.insert(.italic)
            //TODO: check
        }
        if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
            traits.insert(.bold)
        }

        var size = FontSizeCategory.body

        for sizeCategory in ([.body, .title1, .title2, .title3] as [FontSizeCategory]) {
            if font.pointSize == getSize(from: sizeCategory) {
                size = sizeCategory
                break
            }
        }

        return PianoFontAttribute(traits: traits, sizeCategory: size)
    }
}
