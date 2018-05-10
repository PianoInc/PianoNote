//
//  PianoViewData.swift
//  PianoNote
//
//  Created by Kevin Kim on 24/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation
import CoreGraphics

class AnimatableText {
    let label: Label
    let range: NSRange
    let rect: CGRect
    let center: CGPoint
    let text: String
    var attrs: [NSAttributedStringKey : Any]
    
    init(
        label: Label,
        range: NSRange,
        rect: CGRect,
        center: CGPoint,
        text: String,
        attrs: [NSAttributedStringKey : Any]) {
        
        self.label = label
        self.range = range
        self.rect = rect
        self.center = center
        self.text = text
        self.attrs = attrs
    }
}



