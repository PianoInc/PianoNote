//
//  DRAlbumFolderCell.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRAlbumFolderCell: UITableViewCell {
    
    weak var delegates: DRAlbumDelegates!
    
    let thumbnailView = makeView(UIImageView()) {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    let titleLabel = makeView(UILabel()) {
        $0.textColor = .black
    }
    let countLabel = makeView(UILabel()) {
        $0.textColor = .gray
    }
    let button = UIButton()
    
    var indexPath: IndexPath!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        button.addTarget(self, action: #selector(action(select:)), for: .touchUpInside)
        contentView.addSubview(thumbnailView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(button)
    }
    
    private func initConst() {
        makeConst(thumbnailView) {
            $0.leading.equalTo(self.minSize * 0.04)
            $0.top.equalTo(self.minSize * 0.04)
            $0.bottom.equalTo(-(self.minSize * 0.04))
            $0.width.equalTo(self.minSize * 0.2266)
        }
        makeConst(titleLabel) {
            $0.leading.equalTo(self.thumbnailView.snp.trailing).offset(self.minSize * 0.04)
            $0.top.equalTo(self.minSize * 0.04)
            $0.bottom.equalTo(-(self.minSize * 0.1333))
            $0.width.lessThanOrEqualToSuperview().inset(self.minSize * 0.2666)
        }
        makeConst(countLabel) {
            $0.leading.equalTo(self.thumbnailView.snp.trailing).offset(self.minSize * 0.04)
            $0.top.equalTo(self.minSize * 0.1333)
            $0.bottom.equalTo(-(self.minSize * 0.04))
            $0.width.lessThanOrEqualToSuperview().inset(self.minSize * 0.2666)
        }
        makeConst(button) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
    }
    
    @objc private func action(select: UIButton) {
        delegates.select(folder: indexPath)
    }
    
}

