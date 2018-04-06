//
//  InteractiveLayoutManager.swift
//  InteractiveTextEngine
//
//  Created by 김범수 on 2018. 3. 23..
//

import UIKit

class InteractiveLayoutManager: NSLayoutManager {
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let stringRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        
        textStorage?.enumerateAttribute(.attachment, in: stringRange,
                                        options: [.longestEffectiveRangeNotRequired, .reverse]) { (value, range, _) in

            let currentGlyphRange = glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            guard let container = textContainer(forGlyphAt: currentGlyphRange.location, effectiveRange: nil),
                let attachment = value as? InteractiveTextAttachment else {return}

            //Fix bounds for attachment!!

            let currentBounds = self.boundingRect(forGlyphRange: currentGlyphRange, in: container)
            attachment.currentBounds = currentBounds
        }

        textStorage?.enumerateAttribute(.animatingBackground, in: stringRange,
                options: .longestEffectiveRangeNotRequired) { value, range, _ in

            let currentGlyphRange = glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            guard let container = textContainer(forGlyphAt: currentGlyphRange.location, effectiveRange: nil),
                  let layer = value as? InteractiveBackgroundLayer else {return}

            layer.frame = boundingRect(forGlyphRange: currentGlyphRange, in: container).offsetBy(dx: 0, dy: 8)
        }


        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    }
}

extension NSAttributedStringKey {
    public static let animatingBackground = NSAttributedStringKey(rawValue: "animatingBackground")
}
