//
//  DRAlbumView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

/// 화질을 보장받는 최소의 image size.
let PHImageManagerMinimumSize: CGFloat = 130

struct AlbumInfo {
    var type: PHAssetCollectionType
    var subType: PHAssetCollectionSubtype
    var image: UIImage?
    var title: String?
    var count: Int
}

/// 하위항목의 subview tag.
let isChildComponent: Int = 1000

class DRAlbumView: UIView {
    
    weak var delegates: DRMenuDelegates!
    
    // Temp
    private let upArrow = " ▲"
    private let downArrow = " ▼"
    
    private let folderButton = makeView(UIButton()) {
        $0.setTitleColor(.black, for: .normal)
        $0.tag = isChildComponent
    }
    
    private let libraryButton = makeView(UIButton()) {
        $0.setTitle("showall", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.imageEdgeInsets.right = 20
    }
    
    /// 전체화면 여부.
    private var isFullScreen = false
    /// 전체화면 animate 여부.
    private var isAnimate = false
    
    /// inset, statusFrame을 제외한 preferred height.
    private var preferredHeight: CGFloat {
        return UIScreen.main.bounds.height -
            UIApplication.shared.statusBarFrame.height -
            self.safeInset.top - 43
    }
    
    let albumPhotoView = UXAlbumPhotoView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let albumFolderView = UXAlbumFolderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        backgroundColor = .white
        clipsToBounds = true
        
        folderButton.addTarget(self, action: #selector(action(folder:)), for: .touchUpInside)
        libraryButton.addTarget(self, action: #selector(action(library:)), for: .touchUpInside)
        
        [albumPhotoView, libraryButton, albumFolderView].forEach {addSubview($0)}
        albumPhotoView.delegates = self
        albumFolderView.delegates = self
        
        updateFolderTitle()
        
        device(orientationDidChange: { ori in
            self.initConstraint()
            self.albumPhotoView.reloadData()
        })
    }
    
    /// InputView를 전체화면으로 animate 한다.
    private func fullScreenAnimate() {
        guard let accessoryView = inputAccessoryView, let inputView = inputView else {return}
        
        let height = preferredHeight
        for constraint in inputView.constraints where constraint.firstAttribute == .height {
            constraint.constant = height
        }
        
        isAnimate = true
        UIView.animate(withDuration: 0.35, animations: {
            accessoryView.superview?.frame.origin.y = 0
            accessoryView.superview?.frame.size.height = height
            inputView.superview?.frame.origin.y = 0
            inputView.superview?.frame.size.height = height
            inputView.frame.size.height = height
        }, completion: { finished in
            //self.firstAccessoryViewHidden = true
            self.isAnimate = false
        })
        
        accessoryView.addSubview(folderButton)
        initConstraint()
    }
    
    private func initConstraint() {
        if folderButton.superview != nil {
            folderButton.frame = CGRect(x: 0, y: 43, width: folderButton.bounds.width, height: 43)
            
            let headerWidth: CGFloat = 43 * 1.4
            let maxWidth = UIScreen.main.bounds.width - headerWidth * 2
            if folderButton.bounds.width > maxWidth {folderButton.frame.size.width = maxWidth}
            folderButton.frame.origin.x = UIScreen.main.bounds.width / 2 - folderButton.bounds.width / 2
            
            let originY = folderButton.isSelected ? 0 : -UIScreen.main.bounds.height
            albumFolderView.frame = CGRect(x: 0, y: originY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            let originX = albumFolderView.frame.origin.x + self.safeInset.left
            let sizeWidth = albumFolderView.bounds.width - self.safeInset.left - self.safeInset.right
            let sizeHeight = albumFolderView.bounds.height  - self.safeInset.top - self.safeInset.bottom
            albumFolderView.frame = CGRect(x: originX, y: originY, width: sizeWidth, height: sizeHeight)
        }
        
        libraryButton.isHidden = isFullScreen
        libraryButton.snp.removeConstraints()
        libraryButton.snp.makeConstraints {
            $0.leading.equalTo(self.safeInset.left); $0.width.equalTo(140)
            $0.bottom.equalTo(-self.safeInset.bottom); $0.height.equalTo(isFullScreen ? 0 : 50)
        }
        albumPhotoView.snp.removeConstraints()
        albumPhotoView.snp.makeConstraints {
            $0.top.equalTo(0); $0.leading.equalTo(self.safeInset.left)
            $0.bottom.equalTo(libraryButton.snp.top); $0.trailing.equalTo(-self.safeInset.right)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isAnimate {consistHeight()}
    }
    
    /// inputHeight에 맞추어 height를 유지시킨다.
    private func consistHeight() {
        guard let accessoryView = inputAccessoryView, let inputView = inputView else {return}
        
        let height = isFullScreen ? preferredHeight : inputHeight
        for constraint in inputView.constraints where constraint.firstAttribute == .height {
            constraint.constant = height
        }
        
        accessoryView.superview?.frame.size.height = height
        inputView.superview?.frame.size.height = height
        inputView.frame.size.height = height
    }
    
    @objc private func action(folder: UIButton) {
        folder.isSelected = !folder.isSelected
        folderViewAnimate()
        updateFolderTitle()
    }
    
    @objc private func action(library: UIButton) {
        isFullScreen = !isFullScreen
        albumPhotoView.change(direction: .vertical)
        fullScreenAnimate()
    }
    
    /// 폴더 list 화면을 내리거나 올린다.
    private func folderViewAnimate() {
        let originY = folderButton.isSelected ? 0 : -albumFolderView.bounds.height
        UIView.animate(withDuration: 0.35) {
            self.albumFolderView.frame.origin.y = originY
        }
    }
    
    /// 현재 display 되고 있는 photo folder의 title을 갱신한다.
    private func updateFolderTitle() {
        var title = "album_noTitle".locale
        if let albumInfoTitle = albumPhotoView.albumInfo.title {
            title = albumInfoTitle
        }
        
        let combinedTitle = title + (folderButton.isSelected ? upArrow : downArrow)
        let attr = NSMutableAttributedString(string: combinedTitle)
        attr.addAttributes([NSAttributedStringKey.font :
            UIFont.preferred(font: folderButton.titleLabel!.font.pointSize / 2, weight: .regular),
                            NSAttributedStringKey.baselineOffset : 2.5],
                           range: NSMakeRange(attr.length - 1, 1))
        folderButton.setAttributedTitle(attr, for: .normal)
        
        folderButton.sizeToFit()
        initConstraint()
    }
    
}

extension DRAlbumView: UXAlbumPhotoProtocol, UXAlbumFolderProtocol {
    
    func album(selected photo: UIImage) {
        print(photo)
    }
    
    func album(folder selected: AlbumInfo) {
        albumPhotoView.albumInfo = selected
        albumPhotoView.reloadAlbum()
        
        folderButton.isSelected = false
        folderViewAnimate()
        updateFolderTitle()
    }
    
}

