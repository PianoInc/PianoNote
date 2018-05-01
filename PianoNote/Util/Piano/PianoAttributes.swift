//
//  PianoAttributes.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation
import CoreGraphics

enum PianoAttributes: Int {
    case foregroundColor = 0
    case backgroundColor
    case strikeThrough
    case bold
    case italic
    case underline
    
    func addAttribute(from attr: [NSAttributedStringKey : Any]) -> [NSAttributedStringKey : Any] {
        
        var newAttr = attr
        switch self {
        case .foregroundColor:
            newAttr[.foregroundColor] = ColorManager.shared.pointForeground()
            
        case .backgroundColor:
            newAttr[.backgroundColor] = ColorManager.shared.highlightBackground()
            
        case .strikeThrough:
            newAttr[.strikethroughStyle] = 1
            newAttr[.strikethroughColor] = ColorManager.shared.underLine()
            
        case .bold, .italic:
            let fontAttribute = newAttr[.pianoFontInfo] as? PianoFontAttribute ?? PianoFontAttribute.standard()
            let newTraits = fontAttribute.traits.union( self == .bold ? [.bold] : [.italic])
            let newFontAttribute = PianoFontAttribute(traits: newTraits, sizeCategory: fontAttribute.sizeCategory)

            newAttr[.pianoFontInfo] = newFontAttribute
            newAttr[.font] = newFontAttribute.getFont()

        case .underline:
            newAttr[.underlineStyle] = 1
            newAttr[.underlineColor] = ColorManager.shared.underLine()
        }
        
        return newAttr
        
    }
    
    func removeAttribute(from attr: [NSAttributedStringKey : Any]) -> [NSAttributedStringKey : Any] {
        
        var newAttr = attr
        switch self {
        case .foregroundColor:
            newAttr[.foregroundColor] = Color.basic
            
        case .backgroundColor:
            newAttr[.backgroundColor] = Color.clear
            
        case .strikeThrough:
            newAttr[.strikethroughStyle] = 0
            
        case .bold, .italic:
            let fontAttribute = newAttr[.pianoFontInfo] as? PianoFontAttribute ?? PianoFontAttribute.standard()
            let newTraits = fontAttribute.traits.subtracting(self == .bold ? .bold : .italic)
            let newFontAttribute = PianoFontAttribute(traits: newTraits, sizeCategory: fontAttribute.sizeCategory)

            newAttr[.pianoFontInfo] = newFontAttribute
            newAttr[.font] = newFontAttribute.getFont()

        case .underline:
            newAttr[.underlineStyle] = 0
        }
        
        return newAttr
        
    }
    
}
