//
//  DRDetailCommentCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 29..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRDetailCommentCell: UITableViewCell {
    
    @IBOutlet var portraitImage: UIImageView!
    @IBOutlet var nameLabel: UILabel! { didSet {
        nameLabel.font = UIFont.preferred(font: 13, weight: .bold)
        }}
    @IBOutlet var contentLabel: UILabel! { didSet {
        contentLabel.font = UIFont.preferred(font: 15, weight: .regular)
        }}
    
    @IBOutlet var toolView: UIView! { didSet {
        
        }}
    @IBOutlet var arrowImage: UIImageView!
    @IBOutlet var replyLabel: UILabel! { didSet {
        replyLabel.font = UIFont.preferred(font: 12, weight: .regular)
        }}
    @IBOutlet var timeLabel: UILabel! { didSet {
        timeLabel.font = UIFont.preferred(font: 12, weight: .regular)
        }}
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initConst()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(portraitImage) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
            makeConst(nameLabel) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
            makeConst(contentLabel) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
            makeConst(toolView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
            makeConst(arrowImage) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
            makeConst(replyLabel) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
            makeConst(timeLabel) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
        }
        device(orientationDidChange: { _ in constraint()})
    }
    
}

