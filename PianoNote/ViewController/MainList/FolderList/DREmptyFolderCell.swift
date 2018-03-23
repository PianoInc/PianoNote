//
//  DREmptyFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DREmptyFolderCell: UICollectionViewCell {
    
    @IBOutlet var listView: UITableView!
    let header = DRNoteCellHeader()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        listView.tableHeaderView = header
        device(orientationDidChange: { orientation in
            self.initConst()
        })
        initConst()
    }
    
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        makeConst(header) {
            $0.width.equalToSuperview()
            $0.height.equalTo(self.minSize * 0.39)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.reloadData()
        header.contentView.lockImage.backgroundColor = .blue
        header.contentView.titleLabel.text = "모든메모"
        header.contentView.newTitleLabel.text = "오늘의 당신은 어떤 사람이었나요?"
    }
    
}

extension DREmptyFolderCell: UITableViewDelegate {
    
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

