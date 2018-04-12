//
//  asd.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 29..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UITableView {
    
    /**
     TableView의 headerView에 DRNoteCellHeader를 init한다.
     - parameter height: headerView가 가져야할 높이.
     */
    func initHeaderView(_ height: CGFloat) {
        tableHeaderView = DRNoteCellHeader(height: height)
        let minimumRect = CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        tableFooterView = UIView(frame: minimumRect)
    }
    
    /// 2줄까지 가능한 title만 있는 headerView로 shape를 바꾼다.
    func headerView(multiLine title: String) {
        guard let headerView = tableHeaderView as? DRNoteCellHeader else {return}
        headerView.contentView.subviews.forEach {$0.isHidden = true}
        headerView.contentView.titleLabel.isHidden = false
        headerView.contentView.titleLabel.textAlignment = .center
        headerView.contentView.titleLabel.numberOfLines = 2
        headerView.contentView.titleLabel.font = UIFont.preferred(font: 23, weight: .bold)
        headerView.contentView.titleLabel.text = title
        makeConst(headerView.contentView.titleLabel) {
            $0.leading.equalTo(self.minSize * 0.1066)
            $0.trailing.equalTo(-(self.minSize * 0.1066))
            $0.top.equalTo(self.minSize * 0.0666)
        }
    }
    
    /// 큰 Title만 있는 headerView로 shape를 바꾼다.
    func headerView(large title: String) {
        guard let headerView = tableHeaderView as? DRNoteCellHeader else {return}
        headerView.contentView.subviews.forEach {$0.isHidden = true}
        headerView.contentView.titleLabel.isHidden = false
        headerView.contentView.titleLabel.numberOfLines = 1
        headerView.contentView.titleLabel.font = UIFont.preferred(font: 34, weight: .bold)
        headerView.contentView.titleLabel.text = title
        makeConst(headerView.contentView.titleLabel) {
            $0.leading.equalTo(self.minSize * 0.0613)
            $0.trailing.equalTo(-(self.minSize * 0.0613))
            $0.top.equalTo(self.minSize * 0.04)
        }
    }
    
    /// Offset을 유지하면서 reloadData를 진행한다.
    func refreshData() {
        let offset = contentOffset
        reloadData()
        setContentOffset(offset, animated: false)
    }
    
}

extension UITableViewDelegate {
    
    /**
     해당 scrollView의 contentOffset에 따라 navititleView의 display를 조정한다.
     - parameter scrollView: 판단하고자 하는 scrollView.
     */
    func fadeNavigationTitle(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else {return}
        if let header = tableView.tableHeaderView as? DRNoteCellHeader {
            let alpha = tableView.contentOffset.y / header.contentView.titleLabel.frame.maxY
            guard let titleView = UIWindow.topVC?.navigationItem.titleView else {return}
            UIView.animate(withDuration: 0.25) {
                titleView.alpha = (alpha < 0.8) ? 0 : 1
            }
        }
    }
    
    /**
     해당 scrollView의 contentOffset이 90% 이상 스크롤 되었는지를 판단하여 completion를 호출한다.
     - parameter scrollView: 판단하고자 하는 scrollView.
     - parameter completion: 부합하는 상황에서 호출되는 closure.
     */
    func requestNextData(_ scrollView: UIScrollView, completion: (() -> ())) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        guard currentOffset / maximumOffset > 0.9 else {return}
        completion()
    }
    
}

extension UITableViewDataSource {
    
    /**
     해당 indexPath의 DRContentNoteCell이 section내에서 어디에 위치하는지를 판별한다.
     - note: DRContentNotePosition 참조.
     - parameter indexPath: 셀의 indexPath.
     */
    func cells(position tableView: UITableView, indexPath: IndexPath) -> DRContentNotePosition {
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            return DRContentNotePosition.single
        } else if indexPath.row == 0 {
            return DRContentNotePosition.top
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            return DRContentNotePosition.bottom
        }
        return DRContentNotePosition.middle
    }
    
}

extension UICollectionView {
    
    /// Offset을 유지하면서 reloadData를 진행한다.
    func refreshData() {
        let offset = contentOffset
        reloadData()
        setContentOffset(offset, animated: false)
    }
    
}

