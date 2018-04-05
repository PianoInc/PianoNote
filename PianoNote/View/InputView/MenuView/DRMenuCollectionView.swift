//
//  DRMenuCollectionView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

protocol DRMenuDelegates: NSObjectProtocol {
    /**
     Drawing 화면을 close한다.
     - parameter image : 그림의 전체 image.
     - parameter drawRect : 실제로 그림이 그려진 부분의 rect값.
     */
    func close(drawing image: UIImage?, drawingRect: CGRect)
}

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

extension DRMenuCollectionView: DRMenuDelegates {
    
    func close(drawing image: UIImage?, drawingRect: CGRect) {
        targetView.inputView = nil
        targetView.reloadInputViews()
    }
    
}

extension DRMenuCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: minSize * 0.2, height: collectionView.bounds.height)
    }
    
}

extension DRMenuCollectionView: UICollectionViewDataSource, DRMenuCellDelegates {
    
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
                DRAuth.share.request(camera: {
                    let drawingView = DRDrawingView(rect: viewRect, image: nil)
                    drawingView.delegates = self
                    self.loadCustomInput(view: drawingView)
                    self.device(orientationLock: true)
                })
            } else if indexPath.row == 3 {
                DRAuth.share.request(photo: {
                    let drawingView = DRDrawingView(rect: viewRect, image: nil)
                    drawingView.delegates = self
                    self.loadCustomInput(view: drawingView)
                })
            } else {
                DRAuth.share.request(photo: {
                    let drawingView = DRDrawingView(rect: viewRect, image: nil)
                    drawingView.delegates = self
                    self.loadCustomInput(view: drawingView)
                })
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
        fillCustomInput()
    }
    
}

protocol DRMenuCellDelegates: NSObjectProtocol {
    func action(select indexPath: IndexPath)
}

class DRMenuCollectionCell: UICollectionViewCell {
    
    fileprivate weak var delegates: DRMenuCellDelegates!
    
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

