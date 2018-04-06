//
//  DRAlbumView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

class DRAlbumView: UIView {
    
    weak var delegates: DRMenuDelegates!
    
    private var photoListView: DRAlbumPhotoListView!
    private var folderListView: DRAlbumFolderListView!
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
        initView()
        initConst()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        initConst()
    }
    
    private func initView() {
        backgroundColor = .white
        photoListView = DRAlbumPhotoListView()
        folderListView = DRAlbumFolderListView()
        folderListView.isHidden = true
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
                    let height = UIScreen.main.bounds.height - self.safeInset.top - self.safeInset.bottom
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
                $0.leading.equalTo((UIScreen.main.bounds.width - self.minSize * 0.4) / 2)
                $0.trailing.equalTo(-((UIScreen.main.bounds.width - self.minSize * 0.4) / 2))
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
            let height = libraryButton.isSelected ? UIScreen.main.bounds.height : inputHeight
            for constraint in inputView.constraints where constraint.firstAttribute == .height {
                constraint.constant = height
            }
            inputView.superview?.frame.size.height = height
            inputView.frame.size.height = height
        }
        constraint()
        consistHeight()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    @objc private func action(close: UIButton) {
        delegates.close(album: nil)
    }
    
    @objc private func action(library: UIButton) {
        libraryButton.isSelected = !library.isSelected
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
        }, completion: { finished in
            if !self.folderButton.isSelected {self.folderListView.isHidden = true}
        })
    }
    
}

