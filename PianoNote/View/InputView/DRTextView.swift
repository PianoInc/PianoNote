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
        delegate = self
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if inputViewManager.magnifyAccessoryView.magnifyView.state == .paste {
            return action == #selector(paste(_:))
        }
        inputViewManager.magnifyAccessoryView.magnifyView.cursor()
        return true
    }
    
}

extension DRTextView: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        inputViewManager.magnifyAccessoryView.magnifyView.sync()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        inputViewManager.magnifyAccessoryView.magnifyView.sync()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        inputViewManager.magnifyAccessoryView.magnifyView.cursor()
        return true
    }
    
}

