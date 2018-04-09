//
//  DRAlbumPhotoCell.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRAlbumPhotoCell: UICollectionViewCell {
    
    weak var delegates: DRAlbumDelegates!
    
    let photoView = makeView(UIImageView()) {
        $0.isUserInteractionEnabled = false
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    let button = UIButton()
    
    var indexPath: IndexPath!
    
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
        button.addTarget(self, action: #selector(action(select:)), for: .touchUpInside)
        contentView.addSubview(photoView)
        contentView.addSubview(button)
    }
    
    private func initConst() {
        makeConst(photoView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        makeConst(button) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    @objc private func action(select: UIButton) {
        delegates.select(photo: indexPath)
    }
    
}

