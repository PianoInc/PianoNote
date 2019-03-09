//
//  PianoControl.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class PianoControl: UIControl {

    public weak var pianoable: Pianoable?
    public weak var textAnimatable: TextAnimatable?

    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        guard let pianoable = self.pianoable,
            let textAnimatable = self.textAnimatable else { return false }
        let trigger = pianoable.preparePiano(at: touch)
        textAnimatable.preparePiano(animatableTextsTrigger: trigger)
        textAnimatable.playPiano(at: touch)
        return true
        
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        
        guard let pianoable = self.pianoable,
            let textAnimatable = self.textAnimatable else { return }
        textAnimatable.endPiano { (result) in
            pianoable.endPiano(with: result)
        }
        
    }
  
    override func cancelTracking(with event: UIEvent?) {
        
        guard let pianoable = self.pianoable,
            let textAnimatable = self.textAnimatable else { return }
        textAnimatable.endPiano { (result) in
            pianoable.endPiano(with: result)
        }
        
    }

}
