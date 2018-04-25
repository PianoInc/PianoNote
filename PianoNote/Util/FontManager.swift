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

    private func getSize(from category: FontSizeCategory) -> CGFloat{
        //TODO: 글자크기 고려!
        switch category {
            case .title1: return 24.0
            case .title2: return 22.0
            case .title3: return 20.0
            case .body: return 17.0
        }
    }

    func getFont(for attribute: PianoFontAttribute) -> UIFont {
        let descriptor = getDescriptor(from: attribute.traits)
        let size = getSize(from: attribute.sizeCategory)

        return UIFont(descriptor: descriptor, size: size)
    }
}
