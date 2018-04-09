//
//  RecycleBinViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class RecycleBinViewController: DRViewController {
    
    @IBOutlet private var listView: UITableView! { didSet {
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.initHeaderView(minSize * 0.2133)
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = minSize
        }}
    
    private var selectedIndex = [IndexPath]()
    private var data = [["note0-1"], ["note1-1", "note1-2"], ["note2-1", "not2-2", "not2-3"], ["note4-1", "note4-2", "note4-3", "note4-4"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNaviBar()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(self.safeInset.left).priority(.high)
            $0.trailing.equalTo(-self.safeInset.right).priority(.high)
            $0.top.equalTo(self.statusHeight + self.naviHeight).priority(.high)
            $0.bottom.equalTo(-self.safeInset.bottom).priority(.high)
            $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
            $0.centerX.equalToSuperview().priority(.required)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        navi { (navi, item) in
            item.rightBarButtonItem?.title = "selectAll".locale
            item.titleView = makeView(UILabel()) {
                $0.font = UIFont.preferred(font: 17, weight: .semibold)
                $0.text = "deletedMemo".locale
                $0.alpha = 0
            }
        }
    }()
    
    /// Navigation 설정
    private func initNaviBar() {
        navi { (navi, item) in
            navi.isToolbarHidden = false
            navi.toolbarItems = toolbarItems
            // toolbarItems array 순서 = [item, <-spacer->, item, <-spacer->, item]
            guard let toolbarItems = navi.toolbarItems else {return}
            toolbarItems[0].title = "restore".locale
        }
    }
    
    @IBAction private func naviBar(right item: UIBarButtonItem) {
        let indexData = data.enumerated().flatMap { (section, _) in
            data.enumerated().map { (row, _) in
                IndexPath(row: row, section: section)
            }
        }
        selectedIndex.removeAll()
        indexData.forEach {selectedIndex.append($0)}
        for cell  in listView.visibleCells as! [DRContentNoteCell] {
            cell.select = true
            cell.setNeedsLayout()
        }
        updateSelectCount()
    }
    
    @IBAction private func toolBar(left item: UIBarButtonItem) {
        
    }
    
    @IBAction private func toolBar(right item: UIBarButtonItem) {
        
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
        }
    }
    
}

extension RecycleBinViewController: DRContentNoteDelegates {
    
    func select(indexPath: IndexPath) {
        if selectedIndex.contains(indexPath) {
            selectedIndex.remove(at: selectedIndex.index(of: indexPath)!)
        } else {
            selectedIndex.append(indexPath)
        }
        guard let cell = listView.cellForRow(at: indexPath) as? DRContentNoteCell else {return}
        cell.select = selectedIndex.contains(indexPath)
        cell.setNeedsLayout()
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
        sections.sectionLabel.text = "Section \(section)"
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
        
        cell.noteView.data = "\(indexPath)Take for example the TEXT type. It can contain 65535 bytes of data. Take for example the TEXT type. It can contain 65535 bytes of data."
        
        return cell
    }
    
}

