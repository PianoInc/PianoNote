//
//  DRNoteCellSection.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRNoteCellSection: UITableViewHeaderFooterView {
    
    let sectionLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: .title2)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        contentView.addSubview(sectionLabel)
        initConst()
    }
    
    private func initConst() {
        makeConst(sectionLabel) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
    }
    
}

