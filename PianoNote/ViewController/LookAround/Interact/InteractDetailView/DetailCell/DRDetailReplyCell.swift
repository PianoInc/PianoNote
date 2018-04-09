//
//  DRDetailReplyCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 29..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRDetailReplyCell: UITableViewCell {
    
    @IBOutlet var portraitImage: UIImageView! { didSet {
        portraitImage.layer.cornerRadius = 12.5
        }}
    @IBOutlet private var contentsView: UIView! { didSet {
        contentsView.layer.cornerRadius = 13
        contentsView.layer.shadowRadius = 2.5
        contentsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentsView.layer.shadowColor = UIColor(hex8: "56565626").cgColor
        }}
    @IBOutlet var nameLabel: UILabel! { didSet {
        nameLabel.font = UIFont.preferred(font: 13, weight: .bold)
        }}
    @IBOutlet var contentLabel: UILabel! { didSet {
        contentLabel.font = UIFont.preferred(font: 14, weight: .regular)
        }}
    
    @IBOutlet private var toolView: UIView!
    @IBOutlet var timeLabel: UILabel! { didSet {
        timeLabel.font = UIFont.preferred(font: 12, weight: .regular)
        }}
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initConst()
    }
    
    private func initConst() {
        makeConst(portraitImage) {
            $0.leading.equalTo(self.minSize * 0.1333)
            $0.top.equalTo(self.minSize * 0.016)
            $0.width.equalTo(25)
            $0.height.equalTo(25)
        }
        makeConst(contentsView) {
            $0.leading.equalTo(self.portraitImage.snp.trailing).offset(self.minSize * 0.016)
            $0.trailing.equalTo(-(self.minSize * 0.0213))
            $0.top.equalTo(0)
            $0.bottom.equalTo(-(self.minSize * 0.0933))
        }
        makeConst(nameLabel) {
            $0.leading.equalTo(self.minSize * 0.0346)
            $0.top.equalTo(self.minSize * 0.0346)
        }
        makeConst(contentLabel) {
            $0.leading.equalTo(self.minSize * 0.0346)
            $0.trailing.equalTo(-(self.minSize * 0.0346))
            $0.top.equalTo(self.minSize * 0.0346)
            $0.bottom.equalTo(-(self.minSize * 0.0346))
            $0.height.greaterThanOrEqualTo(0)
        }
        makeConst(toolView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(self.contentsView.snp.bottom)
            $0.bottom.equalTo(0)
        }
        makeConst(timeLabel) {
            $0.leading.equalTo(self.minSize * 0.2933)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
}

