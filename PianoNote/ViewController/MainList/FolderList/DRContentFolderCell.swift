//
//  DRContentFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRContentFolderCell: UICollectionViewCell {
    
    @IBOutlet var listView: UITableView! {
        didSet {
            listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
            listView.contentInset.bottom = minSize * 0.3413
            listView.initHeaderView(minSize * 0.4)
            listView.rowHeight = UITableViewAutomaticDimension
            listView.estimatedRowHeight = 140
        }
    }
    
    var selectedIndex = [IndexPath]()
    var data = [["note0-1"], ["note1-1", "note1-2"], ["note2-1", "not2-2", "not2-3"], ["note4-1", "note4-2", "note4-3", "note4-4"]]
    
    var isEditMode = false {
        didSet {editMode()}
    }
    
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
    
    /// TableView의 normal <-> edit 간의 모드를 전환한다.
    private func editMode() {
        listView.scrollsToTop = !isEditMode
        for cell in self.listView.visibleCells {
            (cell as! DRContentNoteCell).deleteButton.isHidden = !self.isEditMode
            cell.setNeedsLayout()
        }
        selectedIndex.removeAll()
    }
    
}

extension DRContentFolderCell: DRContentNoteDelegates {
    
    func select(indexPath: IndexPath) {
        guard isEditMode else {return}
        if selectedIndex.contains(indexPath) {
            selectedIndex.remove(at: selectedIndex.index(of: indexPath)!)
        } else {
            selectedIndex.append(indexPath)
        }
        if let cell = listView.cellForRow(at: indexPath) as? DRContentNoteCell {
            cell.select = selectedIndex.contains(indexPath)
            cell.setNeedsLayout()
        }
    }
    
}

extension DRContentFolderCell: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        naviTitleShowing(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return minSize * 0.1333
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRNoteCellSection") as! DRNoteCellSection
        sections.sectionLabel.text = "Section \(section)"
        return sections
    }
    
}

extension DRContentFolderCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        cell.position = cells(position: tableView, indexPath: indexPath)
        cell.select = selectedIndex.contains(indexPath)
        cell.indexPath = indexPath
        cell.delegates = self
        
        cell.deleteButton.isHidden = !isEditMode
        cell.noteView.data = "\(indexPath)등산하는 사람들이 서로 부르거나, 외치는 소리. 주로 정상에서 외친다. 등산하는 사람들이 서로 부르거나, 외치는 소리. 주로 정상에서 외친다."
        
        return cell
    }
    
}

