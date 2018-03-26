//
//  DRContentFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRContentFolderCell: UICollectionViewCell {
    
    weak var delegates: DRFolderCellDelegates!
    
    @IBOutlet var listView: UITableView!
    let header = DRNoteCellHeader()
    var data = ""
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let header = listView.tableHeaderView as? DRNoteCellHeader {
            let value = scrollView.contentOffset.y / header.contentView.titleLabel.frame.maxY
            delegates.folderTitle(offset: value)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
}

extension DRContentFolderCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        return cell
    }
    
    /**
     TableView의 headerView에 대한 정의를 한다.
     - parameter tableView: 해당 headerView를 가지는 tableView.
     */
    private func table(viewHeaderView tableView: UITableView) {
        guard let header = tableView.tableHeaderView as? DRNoteCellHeader else {return}
        header.contentView.lockImage.backgroundColor = .blue
        header.contentView.titleLabel.text = data
        header.contentView.newTitleLabel.text = data + "오늘은..."
    }
    
}

