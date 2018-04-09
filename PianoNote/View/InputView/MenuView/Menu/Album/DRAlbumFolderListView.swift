//
//  DRAlbumFolderListView.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRAlbumFolderListView: UIView {
    
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
        backgroundColor = .red
    }
    
    private func initConst() {
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
}

