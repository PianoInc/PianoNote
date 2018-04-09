//
//  DRDetailCommentSection.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 29..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

protocol DRDetailDelegates: NSObjectProtocol {
    /**
     선택된 section이 가지는 댓댓글 row를 expand한다.
     - parameter indexPath : 선택된 section의 indexPath.
     */
    func extend(reply indexPath: IndexPath)
}

class DRDetailCommentSection: UITableViewHeaderFooterView {
    
    weak var delegates: DRDetailDelegates!
    
    private let contentsView = makeView(UIView()) {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 13
        $0.layer.shadowRadius = 2.5
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowColor = UIColor(hex8: "56565626").cgColor
    }
    let portraitImage = makeView(UIImageView()) {
        $0.layer.cornerRadius = 12.5
        $0.contentMode = .scaleAspectFit
    }
    let nameLabel = makeView(UILabel()) {
        $0.textColor = UIColor(hex6: "365899")
        $0.font = UIFont.preferred(font: 13, weight: .bold)
    }
    let contentLabel = makeView(UILabel()) {
        $0.numberOfLines = 0
        $0.font = UIFont.preferred(font: 15, weight: .regular)
    }
    
    private let toolView = UIView()
    private let arrowImage = makeView(UIImageView()) {
        $0.contentMode = .scaleAspectFit
    }
    let replyButton = makeView(UIButton(type: .system)) {
        $0.titleLabel?.font = UIFont.preferred(font: 12, weight: .semibold)
    }
    let timeLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: 12, weight: .regular)
    }
    
    var indexPath: IndexPath!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initView()
        initConst()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        initConst()
    }
    
    private func initView() {
        backgroundColor = .clear
        replyButton.addTarget(self, action: #selector(action(reply:)), for: .touchUpInside)
        contentView.addSubview(contentsView)
        contentsView.addSubview(portraitImage)
        contentsView.addSubview(nameLabel)
        contentsView.addSubview(contentLabel)
        contentView.addSubview(toolView)
        toolView.addSubview(arrowImage)
        toolView.addSubview(replyButton)
        toolView.addSubview(timeLabel)
    }
    
    private func initConst() {
        makeConst(contentsView) {
            $0.leading.equalTo(self.minSize * 0.0213)
            $0.trailing.equalTo(-(self.minSize * 0.0213))
            $0.top.equalTo(0)
            $0.bottom.equalTo(-(self.minSize * 0.0933))
        }
        makeConst(portraitImage) {
            $0.leading.equalTo(self.minSize * 0.0266)
            $0.top.equalTo(self.minSize * 0.016)
            $0.width.equalTo(25)
            $0.height.equalTo(25)
        }
        makeConst(nameLabel) {
            $0.leading.equalTo(self.portraitImage.snp.trailing).offset(self.minSize * 0.0266)
            $0.trailing.equalTo(-(self.minSize * 0.0266))
            $0.top.equalTo(self.portraitImage.snp.top)
            $0.height.equalTo(25)
        }
        makeConst(contentLabel) {
            $0.leading.equalTo(self.minSize * 0.0346)
            $0.trailing.equalTo(-(self.minSize * 0.0346))
            $0.top.equalTo(self.portraitImage.snp.bottom).offset(self.minSize * 0.0133)
            $0.bottom.equalTo(-(self.minSize * 0.0346))
            $0.height.greaterThanOrEqualTo(0)
        }
        makeConst(toolView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(self.contentsView.snp.bottom)
            $0.bottom.equalTo(0)
        }
        makeConst(arrowImage) {
            $0.leading.equalTo(self.minSize * 0.072)
            $0.top.equalTo(self.minSize * 0.0266)
            $0.width.equalTo(15)
            $0.height.equalTo(15)
        }
        makeConst(replyButton) {
            $0.leading.equalTo(self.arrowImage.snp.trailing).offset(self.minSize * 0.0266)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        makeConst(timeLabel) {
            $0.leading.equalTo(self.replyButton.snp.trailing).offset(self.minSize * 0.0266)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    @objc private func action(reply: UIButton) {
        delegates.extend(reply: indexPath)
    }
    
}

