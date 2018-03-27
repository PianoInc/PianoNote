//
//  DRContentNoteCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

protocol DRContentNoteDelegates: NSObjectProtocol {
    /**
     선택된 셀의 indexPath를 전달한다.
     - parameter indexPath: 선택된 셀의 indexPath.
     */
    func select(indexPath: IndexPath)
}

/**
 DRContentNoteCell의 위치가 자신의
 group내에서 어디에 위치하는지에 대한 option값.
 */
enum DRContentNotePosition {
    case top, middle, bottom, single
}

/// NoteCell의 외형을 만들어주는 역활을 하는 Cell.
class DRContentNoteCell: UITableViewCell {
    
    weak var delegates: DRContentNoteDelegates!
    
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet private var contentsView: UIView!
    @IBOutlet private var backRoundedView: UIView!
    @IBOutlet private var roundedView: UIView!
    
    /// NoteCell의 실제 note content를 가지는 view.
    @IBOutlet var noteView: DRContentNoteView!
    @IBOutlet private var button: UIButton!
    
    var position: DRContentNotePosition = .single
    var indexPath: IndexPath!
    var select = false
    
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
        makeConst(noteView) {
            $0.leading.equalTo(6)
            $0.trailing.equalTo(-6)
            $0.top.equalTo(6)
            $0.bottom.equalTo(-6)
            $0.height.greaterThanOrEqualTo(self.minSize * 0.3413)
        }
        makeConst(button) {
            $0.leading.equalTo(0)
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
        // 선택 effect.
        roundedView.layer.borderColor = UIColor(hex6: select ? "1784ff" : "b5b5b5").cgColor
        roundedView.layer.borderWidth = select ? 2 : 0.5
    }
    
    @IBAction private func action(_ button: UIButton) {
        delegates.select(indexPath: indexPath)
    }
    
}

/// NoteCell의 실제 note content를 가지는 view.
class DRContentNoteView: UIView {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initView()
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initView() {
        dateLabel.font = UIFont.preferred(font: 13, weight: .regular)
        titleLabel.font = UIFont.preferred(font: 28, weight: .bold)
        contentLabel.font = UIFont.preferred(font: 16, weight: .regular)
    }
    
    private func initConst() {
        makeConst(dateLabel) {
            $0.leading.equalTo(self.minSize * 0.04)
            $0.trailing.equalTo(-(self.minSize * 0.04))
            $0.top.equalTo(self.minSize * 0.02)
            $0.height.greaterThanOrEqualTo(0)
        }
        makeConst(titleLabel) {
            $0.leading.equalTo(self.minSize * 0.04)
            $0.trailing.equalTo(-(self.minSize * 0.04))
            $0.top.equalTo(self.minSize * 0.08)
            $0.height.greaterThanOrEqualTo(0)
        }
        makeConst(contentLabel) {
            $0.leading.equalTo(self.minSize * 0.04)
            $0.trailing.equalTo(-(self.minSize * 0.04))
            $0.top.equalTo(self.minSize * 0.19)
            $0.bottom.equalTo(-(self.minSize * 0.04))
            $0.height.greaterThanOrEqualTo(0)
        }
    }
    
}

