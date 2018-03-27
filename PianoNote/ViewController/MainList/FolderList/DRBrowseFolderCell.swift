//
//  DRBrowseFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRBrowseFolderCell: UICollectionViewCell {
    
    weak var delegates: DRFolderCellDelegates!
    
    @IBOutlet var listView: UITableView!
    
    private let header = DRNoteCellHeader()
    let data = ["deletedMeno".locale, "infomation".locale, "makeUp".locale, "communication".locale]
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initView()
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initView() {
        header.frame.size.height = minSize * 0.3466
        listView.tableHeaderView = header
        let minimumRect = CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        listView.tableFooterView = UIView(frame: minimumRect)
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
            $0.height.equalTo(self.minSize * 0.4)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.reloadData()
    }
    
}

extension DRBrowseFolderCell: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let header = listView.tableHeaderView as? DRNoteCellHeader {
            let value = scrollView.contentOffset.y / header.contentView.titleLabel.frame.maxY
            delegates.folderTitle(offset: value)
        }
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
        table(viewHeaderView: tableView)
        cell.indexPath = indexPath
        return cell
    }
    
    /**
     TableView의 headerView에 대한 정의를 한다.
     - parameter tableView: 해당 headerView를 가지는 tableView.
     */
    private func table(viewHeaderView tableView: UITableView) {
        guard let header = tableView.tableHeaderView as? DRNoteCellHeader else {return}
        header.contentView.lockImage.backgroundColor = .clear
        header.contentView.titleLabel.text = "lookAround".locale
        header.contentView.newView.isHidden = true
    }
    
}

