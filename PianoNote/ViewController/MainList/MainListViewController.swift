//
//  MainListViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import SnapKit

class MainListViewController: DRViewController {
    
    @IBOutlet private var listView: UICollectionView!
    
    private var tempData = ["둘러보기", "폴더", ""]
    private var destIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNaviBar()
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
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    // Orientation 대응
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let prevIndex = round(listView.contentOffset.x / listView.bounds.width)
        func setContentOffset() {
            let offset = CGPoint(x: prevIndex * listView.bounds.width, y: 0)
            listView.setContentOffset(offset, animated: false)
        }
        coordinator.animateAlongsideTransition(in: nil, animation: { _ in
            self.listView.collectionViewLayout.invalidateLayout()
            setContentOffset()
        }, completion: { _ in
            self.listView.reloadData()
            setContentOffset()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        // 화면 load시 보여지는 화면을 두번째 화면으로 이동시킨다.
        listView.setContentOffset(CGPoint(x: listView.bounds.width, y: 0), animated: false)
        navi { (_, item) in
            item.leftBarButtonItem?.title = "manageFolder".locale
            item.rightBarButtonItem?.title = "select".locale
            item.titleView = makeView(UILabel()) {
                $0.font = UIFont.preferred(font: 17, weight: .semibold)
                $0.text = tempData[1]
                $0.alpha = 0
            }
        }
    }()
    
}

// Navigation configuration.
extension MainListViewController {
    
    /// Navigation 설정
    private func initNaviBar() {
        navi { (navi, _) in
            navi.toolbarItems = toolbarItems
            // toolbarItems array 순서 = [item, <-spacer->, item, <-spacer->, item]
            guard let toolbarItems = navigationController?.toolbarItems?[2] else {return}
            toolbarItems.title = "moveToNext".locale
        }
    }
    
    @IBAction private func naviBar(left item: UIBarButtonItem) {
        if item.title! == "manageFolder".locale {
            
        } else {
            if let cell = listView.visibleCells.first as? DRContentFolderCell {
                let indexData = cell.data.enumerated().flatMap { (section, _) in
                    cell.data.enumerated().map { (row, _) in
                        IndexPath(row: row, section: section)
                    }
                }
                cell.selectedIndex.removeAll()
                indexData.forEach {cell.selectedIndex.append($0)}
                for cell in cell.listView.visibleCells as! [DRContentNoteCell] {
                    cell.select = true
                    cell.setNeedsLayout()
                }
            }
        }
    }
    
    @IBAction private func naviBar(right item: UIBarButtonItem) {
        if let _ = listView.visibleCells.first as? DRBrowseFolderCell {
            
        } else if let cell = listView.visibleCells.first as? DRContentFolderCell {
            listView.isScrollEnabled = !listView.isScrollEnabled
            cell.isEditMode = !listView.isScrollEnabled
            navi { (navi, item) in
                navi.isToolbarHidden = listView.isScrollEnabled
                item.leftBarButtonItem?.title = "\(listView.isScrollEnabled ? "manageFolder" :"selectAll")".locale
                item.rightBarButtonItem?.title = "\(listView.isScrollEnabled ? "select" :"done")".locale
            }
        }
    }
    
    @IBAction private func toolBar(left item: UIBarButtonItem) {
        
    }
    
    @IBAction private func toolBar(center item: UIBarButtonItem) {
        
    }
    
    @IBAction private func toolBar(right item: UIBarButtonItem) {
        
    }
    
}

extension MainListViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 화면 중앙점을 기준으로 index를 계산한다.
        let centerOffset = CGPoint(x: scrollView.contentOffset.x + scrollView.center.x, y: scrollView.center.y)
        guard let indexPath = listView.indexPathForItem(at: centerOffset) else {return}
        initNavi(item: indexPath)
    }
    
    /**
     navigationItem의 title 및 image를 설정한다.
     - parameter indexPath : 현재 보이지는 cell의 indexPath.
     */
    private func initNavi(item indexPath: IndexPath) {
        guard let titleView = navigationItem.titleView as? UILabel else {return}
        titleView.text = tempData[indexPath.row]
        titleView.sizeToFit()
        guard let rightItem = navigationItem.rightBarButtonItem else {return}
        rightItem.title = (indexPath.row == 0) ? "" : "select".locale
        rightItem.image = (indexPath.row == 0) ? nil : nil
        guard let _ = listView.cellForItem(at: indexPath) as? DREmptyFolderCell else {return}
        rightItem.title = ""
        rightItem.image = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 폴더간 이동시 노트 리스트를 처음 위치로 초기화 시킨다.
        if let browseFolderCell = cell as? DRBrowseFolderCell {
            browseFolderCell.listView.setContentOffset(.zero, animated: false)
        }
        if let contentFolderCell = cell as? DRContentFolderCell {
            contentFolderCell.listView.setContentOffset(.zero, animated: false)
        }
        navi { (_, item) in item.rightBarButtonItem?.isEnabled = true}
        if let emptyFolderCell = cell as? DREmptyFolderCell {
            emptyFolderCell.listView.setContentOffset(.zero, animated: false)
            navi { (_, item) in item.rightBarButtonItem?.isEnabled = false}
        }
        // 폴더간 이동시 navigation titleView의 alpha값을 초기화 시킨다.
        destIndexPath = indexPath
        guard let titleView = navigationItem.titleView as? UILabel else {return}
        titleView.alpha = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 기존의 cell로 다시 돌아왔다면 alpha값 복원.
        guard let titleView = navigationItem.titleView as? UILabel else {return}
        titleView.alpha = (destIndexPath == indexPath) ? 1 : 0
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
            return cell
        }
        if tempData[indexPath.row].isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DREmptyFolderCell", for: indexPath) as! DREmptyFolderCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRContentFolderCell", for: indexPath) as! DRContentFolderCell
        return cell
    }
    
}

