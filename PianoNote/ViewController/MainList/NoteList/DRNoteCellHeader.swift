//
//  DRNoteCellHeader.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/**
 TableView의 HeaderView에 autoLayout 적용하기 위해선
 실제 contentView를 한번 더 감싸는 view가 필요하기 때문에 사용되는 View.
 */
class DRNoteCellHeader: UIView {
    
    /// HeaderView의 content를 가지는 view.
    let contentView = DRNoteCellHeaderContentView()
    
    convenience init(height: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = .clear
        addSubview(contentView)
        initConst()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(contentView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
        }
        constraint()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
}

class DRNoteCellHeaderContentView: UIView {
    
    let lockImage = makeView(UIImageView()) {
        $0.contentMode = .scaleAspectFit
    }
    let titleLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: 34, weight: .bold)
    }
    let newView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "eaebed")
        $0.layer.cornerRadius = 14
    }
    private let newSubLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: 13, weight: .regular)
        $0.textColor = UIColor(hex6: "8a8a8f")
        $0.text = "newMemoSubText".locale
    }
    let newTitleLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: 16, weight: .regular)
    }
    private let newPlusImage = makeView(UIImageView()) {
        $0.backgroundColor = .blue
        $0.contentMode = .scaleAspectFit
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = .clear
        addSubview(lockImage)
        addSubview(titleLabel)
        addSubview(newView)
        newView.addSubview(newSubLabel)
        newView.addSubview(newTitleLabel)
        newView.addSubview(newPlusImage)
        initConst()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(lockImage) {
                $0.leading.equalTo(self.minSize * 0.0613)
                $0.top.equalTo(self.minSize * 0.0266)
                $0.height.equalTo(15)
                $0.width.equalTo(15)
            }
            makeConst(titleLabel) {
                $0.leading.equalTo(self.minSize * 0.0613)
                $0.trailing.equalTo(-(self.minSize * 0.0613))
                $0.top.equalTo(self.lockImage.snp.bottom)
                $0.height.greaterThanOrEqualTo(0)
            }
            makeConst(newView) {
                $0.leading.equalTo(self.minSize * 0.0533)
                $0.trailing.equalTo(-(self.minSize * 0.0533))
                $0.bottom.equalTo(0)
                $0.height.equalTo(self.minSize * 0.16)
            }
            makeConst(newSubLabel) {
                $0.leading.equalTo(self.minSize * 0.0533)
                $0.trailing.equalTo(-(self.minSize * 0.0533))
                $0.top.equalTo(0)
                $0.height.equalToSuperview().multipliedBy(0.5)
            }
            makeConst(newPlusImage) {
                $0.trailing.equalTo(-(self.minSize * 0.04))
                $0.bottom.equalTo(-(self.minSize * 0.032))
                $0.height.equalTo(20)
                $0.width.equalTo(20)
            }
            makeConst(newTitleLabel) {
                $0.leading.equalTo(self.minSize * 0.0533)
                $0.trailing.equalTo(self.newPlusImage.snp.leading)
                $0.bottom.equalTo(0)
                $0.height.equalToSuperview().multipliedBy(0.7)
            }
        }
        constraint()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
}

