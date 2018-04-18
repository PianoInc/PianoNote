//
//  DRContentFolderCell.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RealmSwift

class DRContentFolderCell: UICollectionViewCell {
    
    @IBOutlet var listView: UITableView! { didSet {
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.initHeaderView(minSize * 0.4)
//        listView.tableHeaderView.delegate = self
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = minSize *  0.3703
        }}
    @IBOutlet var lockView: UIView!
    @IBOutlet private var lockimage: UIImageView!
    @IBOutlet private var lockTitleLabel: UILabel! { didSet {
        lockTitleLabel.font = UIFont.preferred(font: 20, weight: .bold)
        lockTitleLabel.text = "lockTitle".locale
        }}
    @IBOutlet private var lockButton: UIButton! { didSet {
        lockButton.titleLabel?.font = UIFont.preferred(font: 17, weight: .regular)
        lockButton.setTitle("lockSubtitle".locale, for: .normal)
        }}
    @IBOutlet var emptyLabel: UILabel! { didSet {
        emptyLabel.font = UIFont.preferred(font: 17, weight: .regular)
        emptyLabel.text = "noMemo".locale
        }}
    
    var notificationToken: NotificationToken?
    var notes: Results<RealmNoteModel>?
    
    var tagName: String! {
        didSet {
            guard let realm = try? Realm() else {return}
            notificationToken?.invalidate()
            
            let sortDescriptors = [SortDescriptor(keyPath: "isPinned", ascending: false), SortDescriptor(keyPath: "isModified", ascending: false)]
            
            if tagName.isEmpty {
                notes = realm.objects(RealmNoteModel.self)
                    .filter("isInTrash = false").sorted(by: sortDescriptors)
            } else {
                notes = realm.objects(RealmNoteModel.self)
                    .filter("tags CONTAINS[cd] %@ AND isInTrash = false", RealmTagsModel.tagSeparator+"\(tagName!)"+RealmTagsModel.tagSeparator)
                    .sorted(by: sortDescriptors)
            }
            arrangeResults()
            notificationToken = notes?.observe { [weak self] change in
                DispatchQueue.main.async {
                    switch change {
                    case .initial(_): break
                    case .update(_, _, _, _): self?.arrangeResults()
                    case .error(let error): fatalError(error.localizedDescription)//error!
                    }
                }
            }
            
        }
    }
    
    var data: [[RealmNoteModel]] = []
    
    var selectedIndex = [IndexPath]()
    var isEditMode = false { didSet {
        editMode()
        }}
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
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
            $0.top.equalTo(self.minSize * 0.4).priority(.high)
            $0.bottom.equalTo(0).priority(.high)
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
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        makeConst(lockButton) {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(self.lockTitleLabel.snp.centerY).offset(self.minSize * 0.0826)
        }
        makeConst(emptyLabel) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lockView.isHidden = !isLock
        listView.reloadData()
        listView.isScrollEnabled = !data.isEmpty
        emptyLabel.isHidden = !data.isEmpty
    }
    
    override func prepareForReuse() {
        data = []
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
    

    private func arrangeResults() {
        func isInSameChunk(a: RealmNoteModel, b: RealmNoteModel) -> Bool {
            return (a.isPinned && b.isPinned) || Calendar.current.isDate(a.isModified, inSameDayAs: b.isModified)
        }
        
        data = []
        
        guard let results = notes else {return}
        var tempChunk:[RealmNoteModel] = []
        results.forEach {
            if let last = tempChunk.last {
                if isInSameChunk(a: last, b: $0) {
                    tempChunk.append($0)
                } else {
                    data.append(tempChunk)
                    tempChunk = [$0]
                }
            } else {
                tempChunk.append($0)
            }
        }
        if !tempChunk.isEmpty {
            data.append(tempChunk)
        }

        listView.reloadData()
    }
    
    func deleteSelectedCells() {
        guard let realm = try? Realm() else {return}
        let list = List<RealmNoteModel>()
        list.append(objectsIn: selectedIndex.map {data[$0.section][$0.row]})
        
        try? realm.write {
            list.setValue(true, forKey: Schema.Note.isInTrash)
        }
    }
    
    func getDateText(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "오늘"
        } else if Calendar.current.isDateInYesterday(date) {
            return "어제"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            return dateFormatter.string(from: date)
        }
    }

    @IBAction private func action(lock: UIButton) {
        DRAuth.share.request(auth: {
            self.lockView.isHidden = true
        })
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
            guard let noteVC = UIStoryboard.view(id: "NoteViewController", "Main1") as? NoteViewController else {return}
            let note = data[indexPath.section][indexPath.row]
            noteVC.noteID = note.id
            mainListView.present(view: noteVC)
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
        let sampleNote = data[section].first!
        
        sections.sectionLabel.text = getDateText(from: sampleNote.isModified)
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
        
        let note = data[indexPath.section][indexPath.row]
        cell.noteView.data = String(note.content.prefix(40))
        
        return cell
    }
    
}

