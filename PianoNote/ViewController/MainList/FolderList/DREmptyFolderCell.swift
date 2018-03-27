//
//  DREmptyFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DREmptyFolderCell: UICollectionViewCell {
    
    weak var delegates: DRFolderCellDelegates!
    
    @IBOutlet var listView: UITableView!
    
    private let header = DRNoteCellHeader()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initView()
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initView() {
        header.frame.size.height = minSize * 0.4
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

extension DREmptyFolderCell: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let header = listView.tableHeaderView as? DRNoteCellHeader {
            let value = scrollView.contentOffset.y / header.contentView.titleLabel.frame.maxY
            delegates.folderTitle(offset: value)
        }
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
        table(viewHeaderView: tableView)
        cell.emptyLabel.text = "메모 없음"
        return cell
    }
    
    /**
     TableView의 headerView에 대한 정의를 한다.
     - parameter tableView: 해당 headerView를 가지는 tableView.
     */
    private func table(viewHeaderView tableView: UITableView) {
        guard let header = tableView.tableHeaderView as? DRNoteCellHeader else {return}
        header.contentView.lockImage.backgroundColor = .clear
        header.contentView.titleLabel.text = "빈 폴더"
        header.contentView.newTitleLabel.text = "오늘은..."
    }
    
}

