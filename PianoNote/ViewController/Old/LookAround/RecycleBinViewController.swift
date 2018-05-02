//
//  RecycleBinViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RealmSwift

class RecycleBinViewController: DRViewController {
    
    @IBOutlet private var listView: UITableView! { didSet {
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.initHeaderView(minSize * 0.2133)
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = minSize *  0.3703
        }}
    
    private var selectedIndex = [IndexPath]()
    private var data:[[RealmNoteModel]] = []
    private var notificationToken: NotificationToken?
    private var notes: Results<RealmNoteModel>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObserver()
        initToolBar()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(self.safeInset.left).priority(.high)
            $0.trailing.equalTo(-self.safeInset.right).priority(.high)
            $0.top.equalTo(self.statusHeight + self.naviHeight)
            $0.bottom.equalTo(-self.safeInset.bottom)
            $0.width.lessThanOrEqualTo(self.limitWidth).priority(.required)
            $0.centerX.equalToSuperview().priority(.required)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        listView.headerView(large: "deletedMemo".locale)
        navi { (navi, item) in
            navi.isToolbarHidden = false
            item.rightBarButtonItem?.title = "selectAll".locale
            item.titleView = makeView(UILabel()) {
                $0.font = UIFont.preferred(font: 17, weight: .semibold)
                $0.text = "deletedMemo".locale
                $0.alpha = 0
            }
        }
    }()
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        navigationController?.isToolbarHidden = true
    }
    
    /// ToolbarItems 설정
    private func initToolBar() {
        navi { (navi, _) in
            navi.toolbarItems = toolbarItems
            // toolbarItems array 순서 = [item, <-spacer->, item, <-spacer->, item]
            guard let toolbarItems = navi.toolbarItems else {return}
            toolbarItems[0].title = "restore".locale
            toolbarItems[0].isEnabled = !selectedIndex.isEmpty
            toolbarItems[2].isEnabled = !selectedIndex.isEmpty
            toolbarItems[4].isEnabled = !selectedIndex.isEmpty
        }
    }
    
    @IBAction private func naviBar(right item: UIBarButtonItem) {
        let indexData = data.enumerated().flatMap { (section, data) in
            data.enumerated().map { (row, _) in
                IndexPath(row: row, section: section)
            }
        }
        if indexData.count != selectedIndex.count {
            selectedIndex = indexData
            updateSelect(cell: nil, select: true)
        } else {
            selectedIndex.removeAll()
            updateSelect(cell: nil, select: false)
        }
        updateSelectCount()
    }
    
    @IBAction private func toolBar(left item: UIBarButtonItem) {
        if selectedIndex.count > 0 {
            alertWithOKAction(message: "선택하신 노트를 복원하시겠습니까?") { [weak self] _ in
                guard let selectedIndex = self?.selectedIndex,
                    let data = self?.data,
                    let realm = try? Realm() else {return}
                
                let notes = selectedIndex.map{data[$0.section][$0.row]}
                let list = List<RealmNoteModel>()
                list.append(objectsIn: notes)
                
                try? realm.write {
                    list.setValue(false, forKey: Schema.Note.isInTrash)
                }
                self?.selectedIndex.removeAll()
                self?.updateSelect(cell: nil, select: false)
                self?.updateSelectCount()
            }
        }
    }
    
    @IBAction private func toolBar(right item: UIBarButtonItem) {
        if selectedIndex.count > 0 {
            alertWithOKAction(message: "선택하신 노트를 영구 삭제하시겠습니까?") { [weak self] _ in
                guard let selectedIndex = self?.selectedIndex,
                    let data = self?.data else {return}
                selectedIndex.map{data[$0.section][$0.row]}.forEach {
                    ModelManager.delete(id: $0.id, type: RealmNoteModel.self)
                }
                self?.selectedIndex.removeAll()
                self?.updateSelect(cell: nil, select: false)
                self?.updateSelectCount()
            }
        }
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
    }
    
    /// ToolBar에 있는 count title을 갱신한다.
    private func updateSelectCount() {
        navi { (navi, _) in
            // toolbarItems array 순서 = [item, <-spacer->, item, <-spacer->, item]
            guard let toolbarItems = navi.toolbarItems else {return}
            toolbarItems[2].title = ""
            if selectedIndex.count > 0 {
                toolbarItems[2].title = String(format: "selectMemoCount".locale, selectedIndex.count)
            }
            toolbarItems[0].isEnabled = !selectedIndex.isEmpty
            toolbarItems[2].isEnabled = !selectedIndex.isEmpty
            toolbarItems[4].isEnabled = !selectedIndex.isEmpty
        }
    }
    
    private func setObserver() {
        guard let realm = try? Realm() else {return}
        notes = realm.objects(RealmNoteModel.self).filter("isInTrash = true").sorted(byKeyPath: "isModified", ascending: false)
        arrangeResults()
        notificationToken = notes?.observe {[weak self] change in
            DispatchQueue.main.async {
                switch change {
                case .update(_,_,_,_): self?.arrangeResults()
                default: break
                }
            }
        }
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
    
}

extension RecycleBinViewController: DRContentNoteDelegates {
    
    func select(indexPath: IndexPath, sender: UIButton) {
        if selectedIndex.contains(indexPath) {
            selectedIndex.remove(at: selectedIndex.index(of: indexPath)!)
        } else {
            selectedIndex.append(indexPath)
        }
        updateSelect(cell: indexPath, select: selectedIndex.contains(indexPath))
        updateSelectCount()
    }
    
}

extension RecycleBinViewController: UITableViewDelegate {
    
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

extension RecycleBinViewController: UITableViewDataSource {
    
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
        
        let note = data[indexPath.section][indexPath.row]
        
        cell.noteView.data = note.content
        
        return cell
    }
    
}


