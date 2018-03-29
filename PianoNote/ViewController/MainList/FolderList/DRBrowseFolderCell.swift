//
//  DRBrowseFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRBrowseFolderCell: UICollectionViewCell {
    
    @IBOutlet var listView: UITableView! {
        didSet {
            listView.initHeaderView(minSize * 0.3466)
        }
    }
    
    var data = ["deletedMeno".locale, "infomation".locale, "makeUp".locale, "communication".locale]
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initConst()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(listView) {
                $0.leading.equalTo(0)
                $0.trailing.equalTo(0)
                $0.top.equalTo(0)
                $0.bottom.equalTo(0)
            }
        }
        constraint()
        device(orientationDidChange: { _ in constraint()})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.reloadData()
    }
    
}

extension DRBrowseFolderCell: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        naviTitleShowing(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return minSize * 0.1226
    }
    
}

extension DRBrowseFolderCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRBrowseNoteCell") as! DRBrowseNoteCell
        cell.indexPath = indexPath
        return cell
    }
    
}

