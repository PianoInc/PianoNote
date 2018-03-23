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
        device(orientationDidChange: { orientation in
            self.initConst()
        })
        initConst()
    }
    
    /// Constraints 설정
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(self.safeInset.left).priority(.high)
            $0.trailing.equalTo(-self.safeInset.right).priority(.high)
            $0.top.equalTo(self.statusHeight + self.naviHeight).priority(.high)
            $0.bottom.equalTo(-self.safeInset.bottom).priority(.high)
            $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
            $0.centerX.equalToSuperview().priority(.required)
        }
    }
    
    // Orientation 대응
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let prevIndex = round(listView.contentOffset.x / listView.bounds.width)
        func setContentOffset() {
            let offset = CGPoint(x: prevIndex * listView.bounds.width, y: 0)
            listView.setContentOffset(offset, animated: false)
        }
        coordinator.animateAlongsideTransition(in: nil, animation: { context in
            self.listView.collectionViewLayout.invalidateLayout()
            setContentOffset()
        }, completion: { finished in
            self.listView.reloadData()
            setContentOffset()
        })
    }
    
}

extension MainListViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 화면 중앙점을 기준으로 index를 계산한다.
        let centerOffset = CGPoint(x: scrollView.contentOffset.x + scrollView.center.x, y: scrollView.center.y)
        guard let indexPath = listView.indexPathForItem(at: centerOffset) else {return}
        initNavi(item: indexPath.row)
    }
    
    /**
     navigationItem의 title 및 image를 설정한다.
     - parameter index : 현재 보이지는 화면의 listview index.
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
        //guard let navigationBar = navigationController?.navigationBar else {return}
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
        if indexPath.row == 0 { // 둘러보기
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRBrowseFolderCell", for: indexPath) as! DRBrowseFolderCell
            cell.backgroundColor = .black
            return cell
        }
        if tempData[indexPath.row].isEmpty { // 빈 노트
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DREmptyFolderCell", for: indexPath) as! DREmptyFolderCell
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

