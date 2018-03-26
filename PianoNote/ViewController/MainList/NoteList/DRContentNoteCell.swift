//
//  DRContentNoteCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/**
 DRContentNoteCell의 위치가 자신의
 group내에서 어디에 위치하는지에 대한 option값.
 */
enum DRContentNotePosition {
    case top, middle, bottom, single
}

class DRContentNoteCell: UITableViewCell {
    
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet private var contentsView: UIView!
    @IBOutlet private var backRoundedView: UIView!
    @IBOutlet private var roundedView: UIView!
    
    var position: DRContentNotePosition = .single
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initView()
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initView() {
        backRoundedView.layer.cornerRadius = 14
        roundedView.layer.cornerRadius = 10
        roundedView.layer.borderColor = UIColor(hex6: "b5b5b5").cgColor
        roundedView.layer.borderWidth = 0.5
    }
    
    private func initConst() {
        makeConst(stackView) {
            $0.leading.equalTo(self.minSize * 0.0333)
            $0.trailing.equalTo(-(self.minSize * 0.0333))
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
            $0.height.greaterThanOrEqualTo(140)
        }
        makeConst(deleteButton) {
            $0.leading.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
            $0.width.equalTo(self.minSize * 0.1066)
        }
        makeConst(contentsView) {
            $0.leading.equalTo(self.deleteButton.snp.trailing)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeUpdate()
    }
    
    /**
     backRoundedView가 확장되어야 하는지 아닌지에 따라 높이를 조정하고
     roundedView를 위치에 따라 itemSpcing이 equal하게 되도록 조정한다.
     */
    private func shapeUpdate() {
        // backRoundedView configuration.
        makeConst(backRoundedView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        backRoundedView.snp.updateConstraints {
            if position == .top {
                $0.bottom.equalTo(backRoundedView.layer.cornerRadius * 2)
            } else if position == .middle {
                $0.top.equalTo(-(backRoundedView.layer.cornerRadius * 2))
                $0.bottom.equalTo(backRoundedView.layer.cornerRadius * 2)
            } else if position == .bottom {
                $0.top.equalTo(-(backRoundedView.layer.cornerRadius * 2))
            }
        }
        // roundedView configuration.
        makeConst(roundedView) {
            $0.leading.equalTo(6)
            $0.trailing.equalTo(-6)
            $0.top.equalTo(6)
            $0.bottom.equalTo(-6)
        }
        roundedView.snp.updateConstraints {
            if position == .top {
                $0.bottom.equalTo(-3)
            } else if position == .middle {
                $0.top.equalTo(3)
                $0.bottom.equalTo(-3)
            } else if position == .bottom {
                $0.top.equalTo(3)
            }
        }
    }
    
}

