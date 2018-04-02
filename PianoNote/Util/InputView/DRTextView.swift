//
//  DRTextView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/// InputView Text를 위한 임시 class.
class DRTextView: UITextView {
    
    private var inputViewManager: DRInputViewManager!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        inputViewManager = DRInputViewManager(self)
    }
    
}

