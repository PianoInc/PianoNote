//
//  DREmptyFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DREmptyFolderCell: UICollectionViewCell {
    
    @IBOutlet var listView: UITableView! { didSet {
        listView.initHeaderView(minSize * 0.4)
        }}
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initConst()
    }
    
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.reloadData()
    }
    
}

extension DREmptyFolderCell: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fadeNavigationTitle(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height - tableView.tableHeaderView!.bounds.height
    }
    
}

extension DREmptyFolderCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DREmptyNoteCell") as! DREmptyNoteCell
        cell.emptyLabel.text = "메모 없음"
        return cell
    }
    
}

