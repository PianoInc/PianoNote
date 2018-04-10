//
//  TextAnimatable.swift
//  PianoNote
//
//  Created by Kevin Kim on 24/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation
import CoreGraphics

typealias AnimatableTextsTrigger = () -> [AnimatableText]?

protocol TextAnimatable: class {
    
    func preparePiano(animatableTextsTrigger: AnimatableTextsTrigger)
    
    func playPiano(at touch: Touch)
    func endPiano(completion: @escaping CaptivateResult)
}

extension PianoView: TextAnimatable {

    func preparePiano(animatableTextsTrigger: AnimatableTextsTrigger) {
        
        guard !animating else { return }
        if animatableTexts == nil {
            animatableTexts = animatableTextsTrigger()
        }
    }
    
    func playPiano(at touch: Touch) {
        
        guard animatableTexts != nil, !animating else { return }
        let x = touch.location(in: self).x
        updateCoordinateXs(with: x)
        updateLabels(to: x)
        
    }
    
    func endPiano(completion: @escaping CaptivateResult) {
        animateToOriginalPosition(completion: completion)
    }
    
}
