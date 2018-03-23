//
//  DRContentFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRContentFolderCell: UICollectionViewCell {
    
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
            $0.height.equalTo(150)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.reloadData()
    }
    
}

extension DRContentFolderCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
}

extension DRContentFolderCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        return cell
    }
    
}

