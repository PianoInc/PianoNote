//
//  asd.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 29..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Offset을 유지하면서 reloadData를 진행한다.
    func refreshData() {
        let offset = contentOffset
        reloadData()
        setContentOffset(offset, animated: false)
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

