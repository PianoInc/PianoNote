//
//  DRMagnifyAccessoryView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRMagnifyAccessoryView: UIView {
    
    private weak var textView: UITextView!
    
    let switchButton = makeView(UIButton(type: .custom)) {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 15
    }
    let separatorView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "b2b2b2")
    }
    let magnifyView = makeView(UIView()) {
        $0.backgroundColor = .green
    }
    let eraseButton = makeView(UIButton(type: .custom)) {
        $0.backgroundColor = .blue
    }
    
    convenience init(_ textView: UITextView, frame rect: CGRect) {
        self.init(frame: rect)
        self.textView = textView
        initView()
        initConst()
    }
    
    private func initView() {
        addSubview(switchButton)
        addSubview(separatorView)
        addSubview(magnifyView)
        addSubview(eraseButton)
    }
    
    private func initConst() {
        func constraint() {
            makeConst(switchButton) {
                $0.leading.equalTo(self.minSize * 0.0626)
                $0.top.equalTo(self.minSize * 0.0173)
                $0.width.equalTo(self.minSize * 0.08)
                $0.height.equalTo(self.minSize * 0.08)
            }
            makeConst(separatorView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(self.minSize * 0.1146)
                $0.height.equalTo(0.5)
            }
            makeConst(magnifyView) {
                $0.leading.equalTo(self.minSize * 0.032)
                $0.trailing.equalTo(-(self.minSize * 0.1426))
                $0.top.equalTo(self.minSize * 0.1253)
                $0.bottom.equalTo(-(self.minSize * 0.0106))
            }
            makeConst(eraseButton) {
                $0.leading.equalTo(self.magnifyView.snp.trailing)
                $0.trailing.equalTo(0)
                $0.top.equalTo(self.minSize * 0.1173)
                $0.bottom.equalTo(0)
            }
        }
        constraint()
        device(orientationDidChange: { _ in constraint()})
    }
    
}

