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
    
}

extension UITableViewDelegate {
    
    /**
     해당 scrollView이 contentOffset에 따라 navititleView의 display를 조정한다.
     - parameter scrollView: 판단하고자 하는 scrollView.
     */
    func naviTitleShowing(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else {return}
        if let header = tableView.tableHeaderView as? DRNoteCellHeader {
            let alpha = tableView.contentOffset.y / header.contentView.titleLabel.frame.maxY
            guard let titleView = UIWindow.topVC?.navigationItem.titleView else {return}
            UIView.animate(withDuration: 0.25) {
                titleView.alpha = (alpha < 0.8) ? 0 : 1
            }
        }
    }
    
}

extension UITableViewDataSource {
    
    /**
     해당 indexPath의 cell이 section내에서 어디에 위치하는지를 판별한다.
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

