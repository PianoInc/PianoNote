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
    static private let stylesArray:[UIFontTextStyle] = [.title1, .title2, .title3, .headline, .body,
                                                        .callout, .subheadline, .footnote, .caption1, .caption2]
    var customFont: UIFont?
    
    private init() {}
    
    func register(font: UIFont) {
        customFont = font
    }
    
    func getFont(for style: UIFontTextStyle, with traits: FontTraits = []) -> UIFont {
        
        let stylePoint = UIFont.preferredFont(forTextStyle: style).pointSize
        let baseFont = customFont ?? UIFont.preferredFont(forTextStyle: style)
        
        let traitedFont: UIFont
        
        if !traits.isEmpty {
            guard let newFontDescriptor = baseFont.fontDescriptor.withSymbolicTraits(traits.toSymbolicTraits()) else { print("Font descriptor error!");return baseFont }
            traitedFont = UIFont(descriptor: newFontDescriptor, size: stylePoint)
        } else {
            traitedFont = baseFont
        }
        
        if #available(iOS 11.0, *) {
            let metric = UIFontMetrics(forTextStyle: style)
            return metric.scaledFont(for: traitedFont)
        } else {
            return traitedFont
        }

    }
    
    func getFont(from font: UIFont, with traits: FontTraits) -> UIFont {
        guard let style = FontManager.getStyle(font) else {print("Font size error!!");return font}
        
        let stylePoint = UIFont.preferredFont(forTextStyle: style).pointSize
        let baseFont = font
        
        let traitedFont: UIFont
        
        if !traits.isEmpty {
            guard let newFontDescriptor = baseFont.fontDescriptor.withSymbolicTraits(traits.toSymbolicTraits()) else { print("Font descriptor error!");return baseFont }
            traitedFont = UIFont(descriptor: newFontDescriptor, size: stylePoint)
        } else {
            traitedFont = baseFont
        }
        
        
        if #available(iOS 11.0, *) {
            let metric = UIFontMetrics(forTextStyle: style)
            return metric.scaledFont(for: traitedFont)
        } else {
            return traitedFont
        }
    }
    
    static func isStyle(_ style: UIFontTextStyle, font: UIFont) -> Bool {
        let baseFont = UIFont.preferredFont(forTextStyle: style)
        
        return font.pointSize == baseFont.pointSize
    }
    
    static func getStyle(_ font: UIFont) -> UIFontTextStyle? {
        for style in stylesArray {
            let baseFont = UIFont.preferredFont(forTextStyle: style)
            if font.pointSize == baseFont.pointSize { // leading, trailing 등은 커스텀폰트에서도 일치하는지 확인을 못해봄
                return style
            }
        }
        return nil
    }
    
}
