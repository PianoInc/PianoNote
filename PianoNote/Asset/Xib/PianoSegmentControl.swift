//
//  PianoSegmentControl.swift
//  PianoNote
//
//  Created by Kevin Kim on 21/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class PianoSegmentControl: UIView {
    
    @IBOutlet var buttons: [UIButton]!
    weak var PianoView: PianoView?
    
    @IBAction func tap(_ sender: UIButton) {
        
        buttons.forEach { (button) in
            button.alpha = sender != button ? 0.2 : 1
        }
        
        //TODO: animatableView에게 통신을 보내야함 효과에 대해서 넘겨줘야함
        
    }
    

}
