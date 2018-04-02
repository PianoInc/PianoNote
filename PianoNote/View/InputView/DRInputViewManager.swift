//
//  DRInputViewManager.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRInputViewManager: NSObject {
    
    private weak var textView: UITextView!
    var magnifyAccessoryView: DRMagnifyAccessoryView!
    var menuAccessoryView: DRMenuAccessoryView!
    
    convenience init(_ textView: UITextView) {
        self.init()
        self.textView = textView
        initView()
        initConst()
        keyboard()
    }
    
    private func initView() {
        let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: minSize * 0.2293))
        let backgroundView = UIView(frame: rect)
        textView.inputAccessoryView = backgroundView
        
        magnifyAccessoryView = DRMagnifyAccessoryView(textView, frame: rect)
        magnifyAccessoryView.switchButton.addTarget(self, action: #selector(action(switchs:)), for: .touchUpInside)
        textView.inputAccessoryView?.addSubview(magnifyAccessoryView)
        
        menuAccessoryView = DRMenuAccessoryView(textView, frame: rect)
        menuAccessoryView.switchButton.addTarget(self, action: #selector(action(switchs:)), for: .touchUpInside)
        menuAccessoryView.isHidden = true
        textView.inputAccessoryView?.addSubview(menuAccessoryView)
    }
    
    private func initConst() {
        func constraint() {
            makeConst(magnifyAccessoryView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.height.equalTo(self.minSize * 0.2293)
            }
            makeConst(menuAccessoryView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.height.equalTo(self.minSize * 0.2293)
            }
        }
        constraint()
        device(orientationDidChange: { _ in constraint()})
    }
    
    @objc private func action(switchs: UIButton) {
        magnifyAccessoryView.isHidden = !magnifyAccessoryView.isHidden
        menuAccessoryView.isHidden = !menuAccessoryView.isHidden
    }
    
}

extension DRInputViewManager {
    
    /// Keyboard 대응.
    private func keyboard() {
        device(keyboardWillShow: { height in
            self.textView.inputAccessoryView?.isHidden = false
        })
        device(keyboardDidHide: { height in
            self.textView.inputAccessoryView?.isHidden = true
        })
    }
    
}

