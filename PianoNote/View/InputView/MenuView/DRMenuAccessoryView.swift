//
//  DRMenuAccessoryView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRMenuAccessoryView: UIView {
    
    private weak var textView: UITextView!
    
    let switchButton = makeView(UIButton(type: .custom)) {
        $0.backgroundColor = .black
    }
    let backgroundView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "fafafa")
    }
    let separatorView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "b2b2b2")
    }
    
    convenience init(_ textView: UITextView, frame rect: CGRect) {
        self.init(frame: rect)
        self.textView = textView
        initView()
        initConst()
    }
    
    private func initView() {
        addSubview(switchButton)
        addSubview(backgroundView)
        addSubview(separatorView)
    }
    
    private func initConst() {
        func constraint() {
            makeConst(switchButton) {
                $0.leading.equalTo(self.minSize * 0.0626)
                $0.top.equalTo(self.minSize * 0.0173)
                $0.width.equalTo(self.minSize * 0.08)
                $0.height.equalTo(self.minSize * 0.08)
            }
            makeConst(backgroundView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(self.minSize * 0.1146)
                $0.bottom.equalTo(0)
            }
            makeConst(separatorView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(self.minSize * 0.1146)
                $0.height.equalTo(0.5)
            }
        }
        constraint()
        device(orientationDidChange: { _ in constraint()})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switchButton.layer.cornerRadius = switchButton.bounds.width / 2
    }
    
}

