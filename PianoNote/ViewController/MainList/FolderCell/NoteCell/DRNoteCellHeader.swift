//
//  DRNoteCellHeader.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

protocol DRListHeaderDelegates: NSObjectProtocol {
    ///새 메모 작성 선택에 대한 처리
    func addNewNote()
}

/**
 TableView의 HeaderView에 autoLayout 적용하기 위해선
 실제 contentView를 한번 더 감싸는 view가 필요하기 때문에 사용되는 View.
 */
class DRNoteCellHeader: UIView {
    
    /// HeaderView의 실제 content를 가지는 view.
    let contentView = DRNoteCellHeaderContentView()
    
    convenience init(height: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewDidLoad()
    }
    
    private func viewDidLoad() {
        initView()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func initView() {
        backgroundColor = .clear
        addSubview(contentView)
    }
    
    private func initConst() {
        makeConst(contentView) {
            $0.leading.equalTo(0).priority(.high)
            $0.trailing.equalTo(0).priority(.high)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
            $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
            $0.centerX.equalToSuperview().priority(.required)
        }
    }
    
}

class DRNoteCellHeaderContentView: UIView {
    
    weak var delegates: DRListHeaderDelegates!
    
    let lockImage = makeView(UIImageView()) {
        $0.contentMode = .scaleAspectFit
    }
    let titleLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: 34, weight: .bold)
        $0.text = "AllMemo".locale
    }
    let newButton = makeView(UIButton()) {
        $0.backgroundColor = UIColor(hex6: "eaebed")
        $0.corner(rad: 14)
    }
    let newSubLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: 13, weight: .regular)
        $0.textColor = UIColor(hex6: "8a8a8f")
        $0.text = "newMemoSubText".locale
    }
    let newTitleLabel = makeView(UILabel()) {
        $0.font = UIFont.preferred(font: 16, weight: .regular)
    }
    let newPlusImage = makeView(UIImageView()) {
        $0.backgroundColor = .blue
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewDidLoad()
    }
    
    private func viewDidLoad() {
        initView()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func initView() {
        backgroundColor = .clear
        newButton.addTarget(self, action: #selector(action(new:)), for: .touchUpInside)
        addSubview(lockImage)
        addSubview(titleLabel)
        addSubview(newButton)
        newButton.addSubview(newSubLabel)
        newButton.addSubview(newTitleLabel)
        newButton.addSubview(newPlusImage)
    }
    
    private func initConst() {
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
        makeConst(newButton) {
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
    
    @objc private func action(new: UIButton) {
        delegates.addNewNote()
    }
    
}

