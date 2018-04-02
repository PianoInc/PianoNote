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
    }
    
    private func initView() {
        let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: minSize * 0.2293))
        textView.inputAccessoryView = UIView(frame: rect)
        
        magnifyAccessoryView = DRMagnifyAccessoryView(textView, frame: rect)
        magnifyAccessoryView.switchButton.addTarget(self, action: #selector(action(switchs:)), for: .touchUpInside)
        textView.inputAccessoryView?.addSubview(magnifyAccessoryView)
        
        menuAccessoryView = DRMenuAccessoryView(textView, frame: rect)
        menuAccessoryView.switchButton.addTarget(self, action: #selector(action(switchs:)), for: .touchUpInside)
        menuAccessoryView.isHidden = true
        textView.inputAccessoryView?.addSubview(menuAccessoryView)
    }
    
    @objc private func action(switchs: UIButton) {
        magnifyAccessoryView.isHidden = !magnifyAccessoryView.isHidden
        menuAccessoryView.isHidden = !menuAccessoryView.isHidden
    }
    
}

