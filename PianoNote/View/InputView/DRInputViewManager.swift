//
//  DRInputViewManager.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRInputViewManager: NSObject {
    
    private weak var targetView: UITextView!
    var magnifyAccessoryView: DRMagnifyAccessoryView!
    var menuAccessoryView: DRMenuAccessoryView!
    
    convenience init(_ targetView: UITextView) {
        self.init()
        self.targetView = targetView
        initView()
        initConst()
        keyboard()
    }
    
    private func initView() {
        let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: minSize * 0.2293))
        let backgroundView = UIView(frame: rect)
        targetView.inputAccessoryView = backgroundView
        
        magnifyAccessoryView = DRMagnifyAccessoryView(targetView, frame: rect)
        magnifyAccessoryView.switchButton.addTarget(self, action: #selector(action(switchs:)), for: .touchUpInside)
        backgroundView.addSubview(magnifyAccessoryView)
        
        menuAccessoryView = DRMenuAccessoryView(targetView, frame: rect)
        menuAccessoryView.switchButton.addTarget(self, action: #selector(action(switchs:)), for: .touchUpInside)
        menuAccessoryView.isHidden = true
        backgroundView.addSubview(menuAccessoryView)
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
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func keyboard() {
        device(keyboardWillShow: { [weak self] height in
            self?.targetView.inputAccessoryView?.isHidden = false
        })
        device(keyboardDidHide: { [weak self] height in
            self?.targetView.inputAccessoryView?.isHidden = true
        })
    }
    
    @objc private func action(switchs: UIButton) {
        magnifyAccessoryView.isHidden = !magnifyAccessoryView.isHidden
        menuAccessoryView.isHidden = !menuAccessoryView.isHidden
    }
    
}

