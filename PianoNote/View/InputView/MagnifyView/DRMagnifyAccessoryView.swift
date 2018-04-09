//
//  DRMagnifyAccessoryView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRMagnifyAccessoryView: UIView {
    
    weak var targetView: UITextView!
    
    let switchButton = makeView(UIButton(type: .custom)) {
        $0.backgroundColor = .black
    }
    private let backgroundView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "fafafa")
    }
    private let separatorView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "b2b2b2")
    }
    var magnifyView: DRMagnifyView!
    private let eraseButton = makeView(UIButton(type: .custom)) {
        $0.backgroundColor = .blue
    }
    
    convenience init(_ targetView: UITextView, frame rect: CGRect) {
        self.init(frame: rect)
        self.targetView = targetView
        initView()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func initView() {
        magnifyView = DRMagnifyView(targetView)
        eraseButton.addTarget(self, action: #selector(action(erase:)), for: .touchUpInside)
        addSubview(switchButton)
        addSubview(backgroundView)
        addSubview(separatorView)
        addSubview(magnifyView)
        addSubview(eraseButton)
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
        makeConst(magnifyView) {
            $0.leading.equalTo(self.minSize * 0.032 + self.safeInset.left)
            $0.trailing.equalTo(-(self.minSize * 0.1426 + self.safeInset.right))
            $0.top.equalTo(self.minSize * 0.128)
            $0.bottom.equalTo(-(self.minSize * 0.0106))
        }
        makeConst(eraseButton) {
            $0.leading.equalTo(self.magnifyView.snp.trailing)
            $0.trailing.equalTo(-self.safeInset.right)
            $0.top.equalTo(self.minSize * 0.1146)
            $0.bottom.equalTo(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if switchButton.layer.cornerRadius == 0 {
            switchButton.layer.cornerRadius = switchButton.bounds.width / 2
        }
    }
    
    @objc private func action(erase: UIButton) {
        guard targetView.selectedRange.location != 0 else {return}
        /// 주어진 location과 selectedRange.location사이의 range를 delete한다.
        func deleteWord(at location: Int) {
            let range = NSMakeRange(location, targetView.selectedRange.location - location)
            targetView.layoutManager.textStorage?.deleteCharacters(in: range)
            targetView.selectedRange = NSRange(location: location, length: 0)
        }
        
        let begin = targetView.beginningOfDocument
        var location = targetView.selectedRange.location
        var hasWord = false
        while location > 0 {
            guard let start = targetView.position(from: begin, offset: location - 1) else {return}
            guard let end = targetView.position(from: start, offset: 1) else {return}
            guard let range = targetView.textRange(from: start, to: end) else {return}
            guard let text = targetView.text(in: range) else {return}
            if text.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil {
                hasWord = true
            } else if hasWord {
                deleteWord(at: location)
                break
            }
            location -= 1
            if location == 0 {deleteWord(at: location)}
        }
    }
    
}

