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
        let pointColor = Color.point
        var newAttr = attr
        switch self {
        case .foregroundColor:
            newAttr[.foregroundColor] = pointColor
            
        case .backgroundColor:
            newAttr[.backgroundColor] = pointColor.withAlphaComponent(0.3)
            
        case .strikeThrough:
            newAttr[.strikethroughStyle] = 1
            newAttr[.strikethroughColor] = pointColor
            
        case .bold, .italic:
            let fontAttribute = newAttr[.pianoFontInfo] as? PianoFontAttribute ?? PianoFontAttribute.standard()
            let newTraits = fontAttribute.traits.union( self == .bold ? [.bold] : [.italic])
            let newFontAttribute = PianoFontAttribute(traits: newTraits, sizeCategory: fontAttribute.sizeCategory)

            newAttr[.pianoFontInfo] = newFontAttribute
            newAttr[.font] = newFontAttribute.getFont()

        case .underline:
            newAttr[.underlineStyle] = 1
            newAttr[.underlineColor] = pointColor
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
