//
//  MainListViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import SnapKit

class MainListViewController: UIViewController {
    
    @IBOutlet private var listView: UICollectionView!
    
    private let tempData = ["", "", "폴더1", "폴더2", "폴더3", "폴더4", "폴더5"]
    
    /// 한번만 실행할 Void.
    private lazy var dispatchOnce: Void = {
        listView.setContentOffset(CGPoint(x: listView.bounds.width, y: 0), animated: false)
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
    }
    
    /// Constraints 설정
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(self.safeInset.left)
            $0.trailing.equalTo(-self.safeInset.right)
            $0.top.equalTo(self.statusHeight + self.naviHeight)
            $0.bottom.equalTo(-self.safeInset.bottom)
        }
    }
    
    // Orientation 대응
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let index = round(listView.contentOffset.x / listView.bounds.width)
        func setContentOffset() {
            let width = size.width - safeInset.left - safeInset.right
            listView.setContentOffset(CGPoint(x: index * width, y: 0), animated: false)
        }
        coordinator.animateAlongsideTransition(in: nil, animation: { context in
            self.initConst()
            self.listView.reloadData()
            setContentOffset()
        }, completion: { finished in
            setContentOffset()
        })
    }
    
}

extension MainListViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerOffset = CGPoint(x: scrollView.contentOffset.x + scrollView.center.x, y: scrollView.center.y)
        guard let indexPath = listView.indexPathForItem(at: centerOffset) else {return}
        initNavi(item: indexPath.row)
    }
    
    /**
     navigationItem의 title 및 image를 설정한다.
     - parameter observer : 변화된 Value값 통지.
     */
    private func initNavi(item index: Int) {
        guard let leftItem = navigationItem.leftBarButtonItem else {return}
        guard let rightItem = navigationItem.rightBarButtonItem else {return}
        navigationItem.title = tempData[index]
        if index == 0 {
            leftItem.title = tempData[index]
            rightItem.title = tempData[index]
            rightItem.image = nil
        } else {
            leftItem.title = tempData[index]
            rightItem.title = tempData[index]
            rightItem.image = nil
        }
    }
    
    private func naviTitle(alpha: CGFloat) {
        guard let navigationBar = navigationController?.navigationBar else {return}
        //navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIColor.black.withAlphaComponent(alpha / 100)]
    }
    
}

extension MainListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

extension MainListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRBrowseFolderCell", for: indexPath) as! DRBrowseFolderCell
            cell.backgroundColor = .red
            return cell
        }
        if tempData[indexPath.row].isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DREmptyFolderCell", for: indexPath) as! DREmptyFolderCell
            cell.backgroundColor = .blue
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRContentFolderCell", for: indexPath) as! DRContentFolderCell
        cell.backgroundColor = .green
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 폴더간 이동시 노트 리스트를 처음 위치로 초기화 시킨다.
        if let contentFolderCell = cell as? DRContentFolderCell {
            contentFolderCell.listView.setContentOffset(.zero, animated: false)
        }
    }
    
}

