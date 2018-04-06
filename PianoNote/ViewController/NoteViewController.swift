//
//  NoteViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class NoteViewController: DRViewController {
    
    @IBOutlet private var textView: DRTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
        keyboard()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(textView) {
                $0.leading.equalTo(self.safeInset.left).priority(.high)
                $0.trailing.equalTo(-self.safeInset.right).priority(.high)
                $0.top.equalTo(self.statusHeight + self.naviHeight).priority(.high)
                $0.bottom.equalTo(-self.safeInset.bottom).priority(.high)
                $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
                $0.centerX.equalToSuperview().priority(.required)
            }
        }
        constraint()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func keyboard() {
        device(keyboardWillShow: { [weak self] height in
            self?.textView.contentInset.bottom = height
            self?.textView.scrollIndicatorInsets.bottom = height - 43
        })
        device(keyboardDidHide: { [weak self] height in
            self?.textView.contentInset.bottom = 0
            self?.textView.scrollIndicatorInsets.bottom = 0
        })
    }
    
}

