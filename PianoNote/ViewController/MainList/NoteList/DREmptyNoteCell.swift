//
//  DREmptyNoteCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DREmptyNoteCell: UITableViewCell {
    
    @IBOutlet var emptyLabel: UILabel!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        emptyLabel.font = UIFont.preferred(font: 17, weight: .regular)
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initConst() {
        makeConst(emptyLabel) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
    }
    
}

