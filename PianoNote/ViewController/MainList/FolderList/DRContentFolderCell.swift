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
    let data = [["note0-1"], ["note1-1", "note1-2"], ["note2-1", "not2-2"],
                ["note3-1", "note3-2", "note3-3"], ["note4-1", "note4-2", "note4-3", "note4-4"]]
    
    var isEditMode = false {
        didSet {editMode()}
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        header.frame.size.height = minSize * 0.4
        listView.tableHeaderView = header
        let minimumRect = CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        listView.tableFooterView = UIView(frame: minimumRect)
        listView.contentInset.bottom = minSize * 0.3413
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 140
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.reloadData()
    }
    
    /// TableView의 normal <-> edit 간의 모드를 전환한다.
    private func editMode() {
        listView.scrollsToTop = !isEditMode
        for cell in self.listView.visibleCells {
            (cell as! DRContentNoteCell).deleteButton.isHidden = !self.isEditMode
            cell.setNeedsLayout()
        }
    }
    
}

extension DRContentFolderCell: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let header = listView.tableHeaderView as? DRNoteCellHeader {
            let value = scrollView.contentOffset.y / header.contentView.titleLabel.frame.maxY
            delegates.folderTitle(offset: value)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return minSize * 0.1466
    }
    
}

extension DRContentFolderCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRNoteCellSection") as! DRNoteCellSection
        sections.sectionLabel.text = "Section \(section)"
        return sections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        table(viewHeaderView: tableView)
        cell.position = cells(position: tableView, indexPath: indexPath)
        cell.deleteButton.isHidden = !isEditMode
        return cell
    }
    
    /**
     TableView의 headerView에 대한 정의를 한다.
     - parameter tableView: 해당 headerView를 가지는 tableView.
     */
    private func table(viewHeaderView tableView: UITableView) {
        guard let header = tableView.tableHeaderView as? DRNoteCellHeader else {return}
        header.contentView.lockImage.backgroundColor = .blue
        header.contentView.titleLabel.text = "폴더"
        header.contentView.newTitleLabel.text = "오늘은..."
    }
    
    /**
     해당 indexPath의 cell이 어떤 모습을 가져야 하는지 판별한다.
     - note: DRContentRoundShape 참조.
     - parameter indexPath: 셀의 indexPath.
     */
    private func cells(position tableView: UITableView, indexPath: IndexPath) -> DRContentNotePosition {
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

