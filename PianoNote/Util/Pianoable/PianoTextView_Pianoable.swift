//
//  PianoTextView_Pianoable.swift
//  PianoNote
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation

extension PianoTextView {
    
    /**
     프로토콜에 objc를 붙이기 싫어서 따로 뺌
     */
    var toolbarItems: [BarButtonItem] {
        get {
            let flexibleSpace = BarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil)
            let done = BarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(tapPianoDone(sender:)))
            
            return [flexibleSpace, done, flexibleSpace]
        }
    }
    
    @objc func tapPianoDone(sender: Any) {
        finishPiano()
    }
}
