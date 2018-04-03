//
//  NoteViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet private var textView: DRTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConst(textView) {
            $0.leading.equalTo(self.safeInset.left).priority(.high)
            $0.trailing.equalTo(-self.safeInset.right).priority(.high)
            $0.top.equalTo(self.statusHeight + self.naviHeight).priority(.high)
            $0.bottom.equalTo(-self.safeInset.bottom).priority(.high)
            $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
            $0.centerX.equalToSuperview().priority(.required)
        }
    }
    
}

