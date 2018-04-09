//
//  DRContentFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRContentFolderCell: UICollectionViewCell {
    
    @IBOutlet var listView: UITableView! { didSet {
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.initHeaderView(minSize * 0.4)
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 140
        }}
    @IBOutlet private var lockView: UIView!
    @IBOutlet private var lockimage: UIImageView!
    @IBOutlet private var lockTitleLabel: UILabel! { didSet {
        lockTitleLabel.font = UIFont.preferred(font: 20, weight: .bold)
        lockTitleLabel.text = "lockTitle".locale
        }}
    @IBOutlet private var lockButton: UIButton! { didSet {
        lockButton.titleLabel?.font = UIFont.preferred(font: 17, weight: .regular)
        lockButton.setTitle("lockSubtitle".locale, for: .normal)
        }}
    
    var data = [["note0-1"], ["note1-1", "note1-2"], ["note2-1", "not2-2", "not2-3"], ["note4-1", "note4-2", "note4-3", "note4-4"]]
    
    var selectedIndex = [IndexPath]()
    var isEditMode = false { didSet {
        editMode()
        }}
    var isLock = false
    
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
        makeConst(lockView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(self.minSize * 0.4)
            $0.bottom.equalTo(0)
        }
        makeConst(lockimage) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        makeConst(lockTitleLabel) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.bottom.equalTo(-(self.minSize * 0.7493))
        }
        makeConst(lockButton) {
            $0.leading.equalTo((self.mainSize.width - self.minSize * 0.1493) / 2)
            $0.bottom.equalTo(-(self.minSize * 0.6706))
            $0.width.greaterThanOrEqualTo(self.minSize * 0.1493)
            $0.height.equalTo(self.minSize * 0.0413)
        }
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.reloadData()
        lockView.isHidden = !isLock
    }
    
    /// TableView의 normal <-> edit 간의 모드를 전환한다.
    private func editMode() {
        listView.scrollsToTop = !isEditMode
        for cell in listView.visibleCells as! [DRContentNoteCell] {
            cell.deleteButton.isHidden = !self.isEditMode
            cell.setNeedsLayout()
        }
        selectedIndex.removeAll()
    }
    
}

extension DRContentFolderCell: DRContentNoteDelegates {
    
    func select(indexPath: IndexPath) {
        if isEditMode {
            if selectedIndex.contains(indexPath) {
                selectedIndex.remove(at: selectedIndex.index(of: indexPath)!)
            } else {
                selectedIndex.append(indexPath)
            }
            guard let cell = listView.cellForRow(at: indexPath) as? DRContentNoteCell else {return}
            cell.select = selectedIndex.contains(indexPath)
            cell.setNeedsLayout()
        } else if let mainListView = UIWindow.topVC as? MainListViewController {
            mainListView.present(id: "NoteViewController")
        }
    }
    
}

extension DRContentFolderCell: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fadeNavigationTitle(scrollView)
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

