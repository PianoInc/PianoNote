//
//  DRPageControl.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 28..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRPageControl: UIPageControl {
    
    private let backgroundView = makeView(UIView()) {
        $0.backgroundColor = UIColor(hex6: "4d4d4d").withAlphaComponent(0.75)
        $0.corner(rad: 7.75)
    }
    
    override var currentPage: Int { didSet {
        updateDots()
        }}
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initView()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func initView() {
        insertSubview(backgroundView, at: 0)
    }
    
    private func initConst() {
        makeConst(backgroundView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.height.equalTo(self.minSize * 0.0413)
            $0.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDots()
    }
    
    /// PageContol의 dot을 커스텀 dot으로 적용 및 선택된 page에 대한 alpha값 처리를 진행한다.
    private func updateDots() {
        for (idx, view) in subviews.filter({$0 != backgroundView}).enumerated() {
            if let imageView = view.subviews.first(where: {$0 is UIImageView}) {
                imageView.alpha = (idx == currentPage) ? 1 : 0.5
            } else {
                let imageView = UIImageView(frame: view.bounds)
                imageView.backgroundColor = (idx == 0) ? .clear : .white
                imageView.corner(rad: view.bounds.width / 2)
                imageView.alpha = (idx == currentPage) ? 1 : 0.5
                imageView.image = (idx == 0) ? #imageLiteral(resourceName: "setting") : nil
                imageView.contentMode = .scaleAspectFit
                view.addSubview(imageView)
            }
        }
    }
    
}

