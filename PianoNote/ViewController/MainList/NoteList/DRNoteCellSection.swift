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
        $0.backgroundColor = .clear
        $0.font = UIFont.preferred(font: 23, weight: .bold)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
        contentView.addSubview(sectionLabel)
        initConst()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(sectionLabel) {
                $0.leading.equalTo(self.minSize * 0.08)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
        }
        constraint()
        device(orientationDidChange: { _ in constraint()})
    }
    
}
