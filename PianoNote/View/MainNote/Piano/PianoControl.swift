//
//  PianoControl.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class PianoControl: UIControl {

    public weak var effectable: Effectable?
    public weak var textAnimatable: TextAnimatable?

    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        guard let effectable = self.effectable,
            let textAnimatable = self.textAnimatable else { return false }
        let trigger = effectable.preparePiano(at: touch)
        textAnimatable.preparePiano(animatableTextsTrigger: trigger)
        textAnimatable.playPiano(at: touch)
        return true
        
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        
        guard let effectable = self.effectable,
            let textAnimatable = self.textAnimatable else { return }
        textAnimatable.endPiano { (result) in
            effectable.endPiano(with: result)
        }
        
    }
  
    override func cancelTracking(with event: UIEvent?) {
        
        guard let effectable = self.effectable,
            let textAnimatable = self.textAnimatable else { return }
        textAnimatable.endPiano { (result) in
            effectable.endPiano(with: result)
        }
        
    }

}
