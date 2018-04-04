//
//  DRMenuCollectionView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRMenuCollectionView: UICollectionView {
    
    private weak var targetView: UITextView! { didSet {
        _ = targetView.rx.text.orEmpty.takeUntil(targetView.rx.deallocated).subscribe { text in
            if let _ = self.targetView.undoManager {
                
            }
        }
        }}
    
    private let data = ["Undo", "Redo", "Camera", "Album", "Draw"]
    
    convenience init(_ targetView: UITextView, frame rect: CGRect) {
        self.init(frame: rect, collectionViewLayout: UICollectionViewFlowLayout())
        self.targetView = targetView
        initView()
    }
    
    private func initView() {
        register(DRMenuCollectionCell.self, forCellWithReuseIdentifier: "DRMenuCollectionCell")
        backgroundColor = .clear
        allowsSelection = false
        dataSource = self
        delegate = self
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {return}
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }
    
}

extension DRMenuCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: minSize * 0.2, height: collectionView.bounds.height)
    }
    
}

extension DRMenuCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRMenuCollectionCell", for: indexPath) as! DRMenuCollectionCell
        cell.button.setTitle(data[indexPath.row], for: .normal)
        return cell
    }
    
}

class DRMenuCollectionCell: UICollectionViewCell {
    
    let button = makeView(UIButton(type: .custom)) {
        $0.titleLabel?.font = UIFont.preferred(font: 17, weight: .regular)
        $0.setTitleColor(.black, for: .normal)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = .clear
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        contentView.addSubview(button)
        initConst()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(button) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
        }
        constraint()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
}

