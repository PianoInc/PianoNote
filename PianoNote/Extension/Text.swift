//
//  Text.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation

extension Range where Bound == String.Index {
    func toNSRange() -> NSRange {
        return NSMakeRange(lowerBound.encodedOffset, upperBound.encodedOffset - lowerBound.encodedOffset)
    }
}

extension NSAttributedString {
    func withoutParagraphStyle() -> NSAttributedString {
        
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = ParagraphStyle()
        if mutableAttrString.length != 0 {
            mutableAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, mutableAttrString.length))
        }
        return mutableAttrString
        
    }
}
