//
//  Text.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation

extension String {
    var nsString: NSString {
        return NSString(string: self)
    }
}

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
    
    func getStringWithPianoAttributes() -> (string: String, attributes: [AttributeModel]) {
        var attributes: [AttributeModel] = []
        let myRange = NSMakeRange(0, self.length)
        
        self.enumerateAttribute(.attachment, in: myRange, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let pianoAttribute = AttributeModel(range: range, attribute: (.attachment, value as Any)) {
                attributes.append(pianoAttribute)
            }
        }
        
        self.enumerateAttribute(.font, in: myRange, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let pianoAttribute = AttributeModel(range: range, attribute: (.font, value as Any)) {
                attributes.append(pianoAttribute)
            }
        }
        
        self.enumerateAttribute(.backgroundColor, in: myRange, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let pianoAttribute = AttributeModel(range: range, attribute: (.backgroundColor, value as Any)) {
                attributes.append(pianoAttribute)
            }
        }
        
        self.enumerateAttribute(.foregroundColor, in: myRange, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let pianoAttribute = AttributeModel(range: range, attribute: (.foregroundColor, value as Any)) {
                attributes.append(pianoAttribute)
            }
        }
        
        self.enumerateAttribute(.underlineStyle, in: myRange, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let pianoAttribute = AttributeModel(range: range, attribute: (.underlineStyle, value as Any)) {
                attributes.append(pianoAttribute)
            }
        }
        
        self.enumerateAttribute(.strikethroughStyle, in: myRange, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let pianoAttribute = AttributeModel(range: range, attribute: (.strikethroughStyle, value as Any)) {
                attributes.append(pianoAttribute)
            }
        }
        
        
        return (string: self.string, attributes: attributes)
    }
}
