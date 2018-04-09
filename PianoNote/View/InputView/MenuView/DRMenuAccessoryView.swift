//
//  DRMenuAccessoryView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRMenuAccessoryView: UIView {
    
    private weak var targetView: UITextView!
    
    let switchButton = makeView(UIButton(type: .custom)) {
        $0.backgroundColor = .black
    }
    private let backgroundView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "fafafa")
    }
    private let separatorView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "b2b2b2")
    }
    private var menuListView: DRMenuCollectionView!
    
    convenience init(_ targetView: UITextView, frame rect: CGRect) {
        self.init(frame: rect)
        self.targetView = targetView
        initView()
        initConst()
    }
    
    private func initView() {
        menuListView = DRMenuCollectionView(targetView, frame: bounds)
        addSubview(switchButton)
        addSubview(backgroundView)
        addSubview(separatorView)
        addSubview(menuListView)
    }
    
    private func initConst() {
        makeConst(switchButton) {
            $0.leading.equalTo(self.minSize * 0.0626 + self.safeInset.left)
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
        makeConst(menuListView) {
            $0.leading.equalTo(self.safeInset.left)
            $0.trailing.equalTo(-self.safeInset.right)
            $0.top.equalTo(self.minSize * 0.1173)
            $0.bottom.equalTo(0)
        }
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if switchButton.layer.cornerRadius == 0 {
            switchButton.layer.cornerRadius = switchButton.bounds.width / 2
        }
    }
    
}

