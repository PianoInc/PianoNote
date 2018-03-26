//
//  MainListViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import SnapKit

protocol DRFolderCellDelegates:NSObjectProtocol {
    /**
     폴더 title의 maxY 값을 전달한다.
     - parameter value: 폴더 title의 maxY.
     */
    func folderTitle(offset value: CGFloat)
}

class MainListViewController: UIViewController {
    
    @IBOutlet private var listView: UICollectionView!
    
    private let tempData = ["둘러보기", "폴더", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        device(orientationDidChange: { _ in self.initConst()})
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
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        listView.setContentOffset(CGPoint(x: listView.bounds.width, y: 0), animated: false)
        navigationItem.titleView = makeView(UILabel()) {
            $0.font = UIFont.preferred(font: 17, weight: .semibold)
            $0.text = tempData[1]
            $0.alpha = 0
        }
        guard let leftItem = navigationItem.leftBarButtonItem else {return}
        leftItem.title = "manageFolder".locale
        guard let rightItem = navigationItem.rightBarButtonItem else {return}
        rightItem.title = "select".locale
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
}

// Navigation configuration.
extension MainListViewController {
    
    /// Navigation 설정
    private func initNavigation() {
        // toolbarItems array 순서 = [item, <-spacer->, item, <-spacer->, item]
        navigationController?.toolbarItems = toolbarItems
        if let centerItem = navigationController?.toolbarItems?[2] {
            centerItem.title = "moveToNext".locale
        }
    }
    
    @IBAction private func naviBar(left item: UIBarButtonItem) {
        
    }
    
    @IBAction private func naviBar(right item: UIBarButtonItem) {
        listView.isScrollEnabled = !listView.isScrollEnabled
        navigationController?.isToolbarHidden = listView.isScrollEnabled
        guard let leftItem = navigationItem.leftBarButtonItem else {return}
        leftItem.title = listView.isScrollEnabled ? "manageFolder".locale : "selectAll".locale
        guard let rightItem = navigationItem.rightBarButtonItem else {return}
        rightItem.title = listView.isScrollEnabled ? "select".locale : "done".locale
        if let contentNoteCell = listView.visibleCells.first as? DRContentFolderCell {
            contentNoteCell.isEditMode = !listView.isScrollEnabled
        }
    }
    
    @IBAction private func toolBar(left item: UIBarButtonItem) {
        
    }
    
    @IBAction private func toolBar(center item: UIBarButtonItem) {
        
    }
    
    @IBAction private func toolBar(right item: UIBarButtonItem) {
        
    }
    
}

extension MainListViewController: DRFolderCellDelegates {
    
    func folderTitle(offset value: CGFloat) {
        naviTitle(alpha: value)
    }
    
    /**
     NavigationBar title에 주어진 alpha값을 적용한다.
     - parameter alpha: 적용하려는 alpha값.
     */
    private func naviTitle(alpha: CGFloat) {
        guard let titleView = navigationItem.titleView else {return}
        UIView.animate(withDuration: 0.25) {
            titleView.alpha = (alpha < 0.8) ? 0 : 1
        }
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
        guard let titleView = navigationItem.titleView as? UILabel else {return}
        titleView.text = tempData[index]
        titleView.sizeToFit()
        guard let rightItem = navigationItem.rightBarButtonItem else {return}
        rightItem.title = (index == 0) ? "" : "select".locale
        rightItem.image = (index == 0) ? nil : nil
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
            cell.delegates = self
            return cell
        }
        if tempData[indexPath.row].isEmpty { // 빈 노트
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DREmptyFolderCell", for: indexPath) as! DREmptyFolderCell
            cell.delegates = self
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRContentFolderCell", for: indexPath) as! DRContentFolderCell
        cell.delegates = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 폴더간 이동시 노트 리스트를 처음 위치로 초기화 시킨다.
        if let contentFolderCell = cell as? DRContentFolderCell {
            contentFolderCell.listView.setContentOffset(.zero, animated: false)
        }
    }
    
}

