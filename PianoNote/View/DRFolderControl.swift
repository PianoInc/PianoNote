//
//  DRFolderControl.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 28..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRFolderControl: UIPageControl {
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        currentPageIndicatorTintColor = UIColor.clear
        pageIndicatorTintColor = UIColor.clear
        backgroundColor = UIColor(hex6: "4d4d4d")
        clipsToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        updateDots()
    }
    
    private func updateDots() {
        for (idx, view) in subviews.enumerated() {
            if let imageView = view.subviews.first(where: {$0 is UIImageView}) {
                imageView.alpha = (idx == currentPage) ? 1 : 0.5
            } else {
                let imageView = UIImageView(frame: view.bounds)
                imageView.backgroundColor = (idx == 0) ? .clear : .white
                imageView.layer.cornerRadius = view.bounds.width / 2
                imageView.alpha = (idx == currentPage) ? 1 : 0.3
                imageView.image = (idx == 0) ? #imageLiteral(resourceName: "setting") : nil
                imageView.contentMode = .scaleAspectFit
                view.addSubview(imageView)
            }
        }
    }
    
}

