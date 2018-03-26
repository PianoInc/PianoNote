//
//  BulletFormatter_mac.swift
//  PianoNote
//
//  Created by Kevin Kim on 2018. 2. 23..
//  Copyright © 2018년 piano. All rights reserved.
//

import AppKit

extension NSTextView {
    
    func insertBulletString(_ attrString: NSAttributedString) {
        
        guard let textStorage = textView.textStorage else { return }
        let attrString = NSAttributedString(string: "\n", attributes: defaultAttributesWithoutParaStyle)
        textStorage.insert(attrString, at: textView.selectedRange.location)
        textStorage.replaceCharacters(in: textView.selectedRange, with: attrString)
        textView.scrollRangeToVisible(textView.selectedRange)
        
    }
}

