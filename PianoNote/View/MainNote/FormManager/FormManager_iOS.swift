//
//  BulletFormatter_ios.swift
//  PianoNote
//
//  Created by Kevin Kim on 2018. 2. 23..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UITextView {
    
    func insertBulletString(_ attrString: NSAttributedString) {
        
        insertText("\n")
        textStorage.replaceCharacters(in: selectedRange, with: attrString)
        selectedRange.location += attrString.length
        
    }
}

