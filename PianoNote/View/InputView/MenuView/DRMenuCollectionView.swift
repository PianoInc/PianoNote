//
//  DRMenuCollectionView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRMenuCollectionView: UICollectionView {
    
    private weak var targetView: UITextView!
    private var data = ["No undo", "No redo", "Camera", "Album", "Draw"]
    
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
        
        // 실제 text의 변화에 따른 undo, redo 기능의 enabled 설정.
        _ = targetView.rx.text.orEmpty.takeUntil(targetView.rx.deallocated).subscribe { text in
            if let manager = self.targetView.undoManager {
                self.data[0] = manager.canUndo ? "Undo" : "No undo"
                self.data[1] = manager.canRedo ? "Redo" : "No redo"
                self.reloadItems(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)])
            }
        }
    }
    
}

extension DRMenuCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: minSize * 0.2, height: collectionView.bounds.height)
    }
    
}

extension DRMenuCollectionView: UICollectionViewDataSource, DRMenuDelegates {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRMenuCollectionCell", for: indexPath) as! DRMenuCollectionCell
        cell.indexPath = indexPath
        cell.delegates = self
        cell.button.setTitle(data[indexPath.row], for: .normal)
        return cell
    }
    
    func action(select indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let manager = targetView.undoManager, manager.canUndo else {return}
            manager.undo()
        } else if indexPath.row == 1 {
            guard let manager = targetView.undoManager, manager.canRedo else {return}
            manager.redo()
        } else {
            let viewRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: inputHeight)
            device(orientationLock: false)
            if indexPath.row == 2 {
                loadCustomInput(view: UIView(frame: viewRect))
                device(orientationLock: true)
            } else if indexPath.row == 3 {
                loadCustomInput(view: UIView(frame: viewRect))
            } else {
                loadCustomInput(view: UIView(frame: viewRect))
            }
        }
    }
    
    /**
     Custom inputView의 reload를 진행한다.
     - parameter view : load하고자 하는 custom inputView.
     */
    private func loadCustomInput(view: UIView) {
        targetView.inputView = view
        targetView.reloadInputViews()
        animateCustomInput()
    }
    
    /// InputView를 전체화면으로 animate 한다.
    private func animateCustomInput() {
        guard let accessoryView = targetView.inputAccessoryView else {return}
        guard let inputView = targetView.inputView else {return}
        let offsetY = accessoryView.bounds.height
        let height = UIScreen.main.bounds.height
        
        for const in inputView.constraints where const.firstAttribute == .height {
            const.constant = height
        }
        
        UIView.animate(withDuration: 0.3) {
            accessoryView.superview?.frame.origin.y = offsetY
            accessoryView.superview?.frame.size.height = height
            inputView.superview?.frame.origin.y = offsetY
            inputView.superview?.frame.size.height = height
            inputView.frame.size.height = height
        }
    }
    
}

protocol DRMenuDelegates: NSObjectProtocol {
    func action(select indexPath: IndexPath)
}

class DRMenuCollectionCell: UICollectionViewCell {
    
    fileprivate weak var delegates: DRMenuDelegates!
    
    fileprivate let button = makeView(UIButton(type: .custom)) {
        $0.titleLabel?.font = UIFont.preferred(font: 17, weight: .regular)
        $0.setTitleColor(.black, for: .normal)
    }
    
    fileprivate var indexPath: IndexPath!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = .clear
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(action(select:)), for: .touchUpInside)
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
    
    @objc private func action(select: UIButton) {
        delegates.action(select: indexPath)
    }
    
}

