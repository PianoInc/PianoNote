//
//  DRAlbumPhotoListView.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRAlbumPhotoListView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initConst()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        initConst()
    }
    
    private func initView() {
        backgroundColor = .blue
    }
    
    private func initConst() {
        func constraint() {
            
        }
        constraint()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
}

