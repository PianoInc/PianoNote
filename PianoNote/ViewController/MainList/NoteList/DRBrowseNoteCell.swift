//
//  DRBrowseNoteCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRBrowseNoteCell: UITableViewCell {
    
    @IBOutlet private var roundedView: UIView!
    @IBOutlet private var iconImage: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var notiLabel: UILabel!
    @IBOutlet private var notiImage: UIImageView!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initView()
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initView() {
        roundedView.layer.cornerRadius = 14
        iconImage.backgroundColor = .blue
        titleLabel.font = UIFont.preferred(font: 12, weight: .semibold)
        notiLabel.font = UIFont.preferred(font: 12, weight: .semibold)
        notiImage.layer.cornerRadius = 3.5
    }
    
    private func initConst() {
        makeConst(roundedView) {
            $0.leading.equalTo(self.minSize * 0.04)
            $0.trailing.equalTo(-(self.minSize * 0.04))
            $0.top.equalTo(3)
            $0.bottom.equalTo(-3)
        }
        makeConst(iconImage) {
            $0.leading.equalTo(self.minSize * 0.0466)
            $0.top.equalTo(self.minSize * 0.028)
            $0.bottom.equalTo(-(self.minSize * 0.028))
            $0.width.equalTo(16.5)
        }
        makeConst(titleLabel) {
            $0.leading.equalTo(self.minSize * 0.1213)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        makeConst(notiLabel) {
            $0.trailing.equalTo(-(self.minSize * 0.0653))
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        makeConst(notiImage) {
            $0.trailing.equalTo(-(self.minSize * 0.0653))
            $0.top.equalTo(self.minSize * 0.0426)
            $0.width.equalTo(7)
            $0.height.equalTo(7)
        }
    }
    
}

