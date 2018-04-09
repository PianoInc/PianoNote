//
//  DRAlbumView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

/// 최소한의 화질을 보장받을 수 있는 image size 값.
let PHImageManagerMinimumSize: CGFloat = 125

protocol DRAlbumDelegates: NSObjectProtocol {
    /**
     Photo 선택에 대한 처리를 진행한다.
     - parameter indexPath : 선택한 photo의 indexPath.
     */
    func select(photo indexPath: IndexPath)
    /**
     Folder 선택에 대한 처리를 진행한다.
     - parameter indexPath : 선택한 folder의 indexPath.
     */
    func select(folder indexPath: IndexPath)
}

class DRAlbumView: UIView {
    
    weak var delegates: DRMenuDelegates!
    
    private var photoListView: DRAlbumPhotoListView! { didSet {
        photoListView.delegates = self
        updateTitle()
        }}
    private var folderListView: DRAlbumFolderListView! { didSet {
        folderListView.delegates = self
        folderListView.isHidden = true
        }}
    private let coverView = makeView(UIView()) {
        $0.backgroundColor = .white
    }
    private let folderButton = makeView(UIButton()) {
        $0.backgroundColor = .purple
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("album", for: .normal)
    }
    private let closeButton = makeView(UIButton()) {
        $0.backgroundColor = .yellow
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("close", for: .normal)
    }
    private let libraryButton = makeView(UIButton()) {
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("showall", for: .normal)
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
        backgroundColor = .white
        photoListView = DRAlbumPhotoListView()
        folderListView = DRAlbumFolderListView()
        folderButton.addTarget(self, action: #selector(action(folder:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(action(close:)), for: .touchUpInside)
        libraryButton.addTarget(self, action: #selector(action(library:)), for: .touchUpInside)
        addSubview(photoListView)
        addSubview(folderListView)
        addSubview(coverView)
        addSubview(folderButton)
        addSubview(closeButton)
        addSubview(libraryButton)
    }
    
    private func initConst() {
        func constraint() {
            makeConst(photoListView) {
                $0.leading.equalTo(self.safeInset.left)
                $0.trailing.equalTo(-self.safeInset.right)
                if self.libraryButton.isSelected {
                    $0.top.equalTo(self.minSize * 0.1146 + self.safeInset.top)
                    $0.bottom.equalTo(-(self.safeInset.bottom))
                } else {
                    $0.top.equalTo(0)
                    $0.bottom.equalTo(-(self.minSize * 0.1146 + self.safeInset.bottom))
                }
            }
            makeConst(folderListView) {
                $0.leading.equalTo(self.safeInset.left)
                $0.trailing.equalTo(-self.safeInset.right)
                $0.bottom.equalTo(self.photoListView.snp.top)
                if self.libraryButton.isSelected {
                    let height = self.mainSize.height - self.safeInset.top - self.safeInset.bottom
                    let folderButtonHeight = self.minSize * 0.1146
                    $0.height.equalTo(height - folderButtonHeight)
                } else {
                    $0.height.equalTo(0)
                }
            }
            makeConst(coverView) {
                $0.leading.equalTo(self.safeInset.left)
                $0.trailing.equalTo(-self.safeInset.right)
                $0.top.equalTo(0)
                $0.bottom.equalTo(self.photoListView.snp.top)
            }
            closeButton.isHidden = !self.libraryButton.isSelected
            makeConst(closeButton) {
                $0.leading.equalTo(self.safeInset.left)
                $0.top.equalTo(self.safeInset.top)
                $0.width.equalTo(self.minSize * 0.3)
                $0.height.equalTo(self.minSize * 0.1146)
            }
            folderButton.isHidden = !self.libraryButton.isSelected
            makeConst(folderButton) {
                $0.leading.equalTo((self.mainSize.width - self.minSize * 0.4) / 2)
                $0.trailing.equalTo(-((self.mainSize.width - self.minSize * 0.4) / 2))
                $0.top.equalTo(self.safeInset.top)
                $0.height.equalTo(self.minSize * 0.1146)
            }
            libraryButton.isHidden = self.libraryButton.isSelected
            makeConst(libraryButton) {
                $0.leading.equalTo(self.safeInset.left)
                $0.bottom.equalTo(-(self.safeInset.bottom))
                $0.width.equalToSuperview().multipliedBy(0.2)
                $0.height.equalTo(self.minSize * 0.1146)
            }
        }
        func consistHeight() {
            guard let inputView = inputView else {return}
            let height = libraryButton.isSelected ? mainSize.height : inputHeight
            for constraint in inputView.constraints where constraint.firstAttribute == .height {
                constraint.constant = height
            }
            inputView.superview?.frame.size.height = height
            inputView.frame.size.height = height
        }
        constraint()
        consistHeight()
    }
    
    @objc private func action(close: UIButton) {
        delegates.close(album: nil)
    }
    
    @objc private func action(library: UIButton) {
        libraryButton.isSelected = !library.isSelected
        photoListView.change(direction: .vertical)
        fillCustomInput()
        initConst()
    }
    
    @objc private func action(folder: UIButton) {
        folderButton.isSelected = !folder.isSelected
        let upperOffset = folderButton.bounds.height + self.safeInset.top
        let offset = folderButton.isSelected ? upperOffset : -(folderListView.bounds.height - upperOffset)
        if folderButton.isSelected {folderListView.isHidden = false}
        UIView.animate(withDuration: 0.3, animations: {
            self.folderListView.frame.origin.y = offset
        }, completion: { _ in
            if !self.folderButton.isSelected {self.folderListView.isHidden = true}
        })
    }
    
    /// 현재 display 되고 있는 folder에 따라 title을 갱신한다.
    private func updateTitle() {
        let str = photoListView.albumTitle + (folderButton.isSelected ? " ▲" : " ▼")
        let attStr = NSMutableAttributedString(string: str)
        attStr.addAttributes([NSAttributedStringKey.font :
            UIFont.preferred(font: folderButton.titleLabel!.font.pointSize / 2, weight: .regular),
                              NSAttributedStringKey.baselineOffset : 2.5],
                             range: NSMakeRange(attStr.length - 1, 1))
        folderButton.setAttributedTitle(attStr, for: .normal)
    }
    
}

extension DRAlbumView: DRAlbumDelegates {
    
    func select(photo indexPath: IndexPath) {
        
    }
    
    func select(folder indexPath: IndexPath) {
        photoListView.requestPhoto(from: folderListView.albumAssets[indexPath.row])
        action(folder: folderButton)
        updateTitle()
    }
    
}

