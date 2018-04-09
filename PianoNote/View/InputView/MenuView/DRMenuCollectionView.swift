//
//  DRMenuCollectionView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRMenuCollectionView: UICollectionView {
    
    weak var targetView: UITextView!
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        // 실제 text의 변화에 따른 undo, redo 기능의 enabled 설정.
        _ = targetView.rx.text.orEmpty.takeUntil(targetView.rx.deallocated).subscribe { text in
            if let manager = self.targetView?.undoManager {
                self.data[0] = manager.canUndo ? "Undo" : "No undo"
                self.data[1] = manager.canRedo ? "Redo" : "No redo"
                self.refreshData()
            }
        }
    }()
    
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
        cell.indexPath = indexPath
        cell.delegates = self
        cell.button.setTitle(data[indexPath.row], for: .normal)
        return cell
    }
    
}

class DRMenuCollectionCell: UICollectionViewCell {
    
    fileprivate weak var delegates: DRMenuDelegates!
    
    fileprivate let button = makeView(UIButton(type: .custom)) {
        $0.titleLabel?.font = UIFont.preferred(font: 17, weight: .regular)
        $0.setTitleColor(.black, for: .normal)
    }
    
    fileprivate var indexPath: IndexPath!
    
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
        backgroundColor = .clear
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(action(select:)), for: .touchUpInside)
        contentView.addSubview(button)
    }
    
    private func initConst() {
        makeConst(button) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
    }
    
    @objc private func action(select: UIButton) {
        delegates.action(select: indexPath)
    }
    
}

