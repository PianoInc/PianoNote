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
    
    private var notificationToken: NotificationToken?
    private var notes: Results<RealmNoteModel>?
    
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
            
            if let headerView = listView.tableHeaderView as? DRNoteCellHeader {
                headerView.contentView.delegates = self
                headerView.contentView.titleLabel.text = tagName.isEmpty ? "AllMemo".locale : tagName
            }
            listView.reloadData()
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
            $0.top.equalTo(self.minSize * 0.4).priority(.high)
            $0.bottom.equalTo(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

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
        updateSelect(cell: nil, select: !self.isEditMode)
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
    
    /**
     선택된 cell의 삭제를 진행한다.
     - parameter hidden : Delete 버튼의 hidden 유무.
     */
    func deleteSelectedCells(_ hidden: Bool = true) {
        guard let realm = try? Realm() else {return}
        let list = List<RealmNoteModel>()
        list.append(objectsIn: selectedIndex.map {data[$0.section][$0.row]})
        
        try? realm.write {
            list.setValue(true, forKey: Schema.Note.isInTrash)
        }
        
        selectedIndex.removeAll()
        updateSelect(cell: nil, select: false)
    }
    
    @IBAction private func action(lock: UIButton) {
        DRAuth.share.request(auth: {
            self.lockView.isHidden = true
        })
    }
    
    private func updateSelect(cell indexPath: IndexPath?, select: Bool) {
        if let indexPath = indexPath, let cell = listView.cellForRow(at: indexPath) as? DRContentNoteCell {
            cell.select = select
            cell.setNeedsLayout()
        } else {
            for cell in listView.visibleCells as! [DRContentNoteCell] {
                cell.select = select
                cell.setNeedsLayout()
            }
        }
        guard let mainListView = UIWindow.topVC as? MainListViewController else {return}
        guard let toolbarItems = mainListView.navigationController?.toolbarItems else {return}
        toolbarItems[0].isEnabled = !selectedIndex.isEmpty
        toolbarItems[2].isEnabled = !selectedIndex.isEmpty
        toolbarItems[4].isEnabled = !selectedIndex.isEmpty
    }
    
}

extension DRContentFolderCell: DRListHeaderDelegates, DRContentNoteDelegates {
    
    func addNewNote() {
        let newModel = RealmNoteModel.getNewModel(content: "", categoryRecordName: tagName)
        ModelManager.saveNew(model: newModel)
        guard let mainListView = UIWindow.topVC as? MainListViewController else {return}
        guard let noteVC = UIStoryboard.view(id: "NoteViewController", "Main1") as? NoteViewController else {return}
        noteVC.noteID = newModel.id
        mainListView.present(view: noteVC)
    }
    
    func select(indexPath: IndexPath, sender: UIButton) {
        guard sender.tag == 0 else {
            selectedIndex.append(indexPath)
            deleteSelectedCells(false)
            return
        }
        if isEditMode {
            if selectedIndex.contains(indexPath) {
                selectedIndex.remove(at: selectedIndex.index(of: indexPath)!)
            } else {
                selectedIndex.append(indexPath)
            }
            updateSelect(cell: indexPath, select: selectedIndex.contains(indexPath))
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
        sections.sectionLabel.text = sampleNote.isModified.timeFormat
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

