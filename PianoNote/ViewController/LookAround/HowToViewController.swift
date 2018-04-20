//
//  HowToViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 11..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class HowToViewController: DRViewController {
    
    @IBOutlet private var listView: UITableView! { didSet {
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.initHeaderView(minSize * 0.2133)
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = minSize *  0.3703
        }}
    
    private let data = [["note0-1"], ["note1-1", "note1-2"], ["note2-1", "not2-2", "not2-3"], ["note4-1", "note4-2", "note4-3", "note4-4"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
    }
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(self.safeInset.left).priority(.high)
            $0.trailing.equalTo(-self.safeInset.right).priority(.high)
            $0.top.equalTo(self.statusHeight + self.naviHeight)
            $0.bottom.equalTo(-self.safeInset.bottom)
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
        listView.headerView(large: "howTo".locale)
        navi { (navi, item) in
            item.rightBarButtonItem?.title = "selectAll".locale
            item.titleView = makeView(UILabel()) {
                $0.font = UIFont.preferred(font: 17, weight: .semibold)
                $0.text = "howTo".locale
                $0.alpha = 0
            }
        }
    }()
    
}

extension HowToViewController: DRContentNoteDelegates {
    
    func select(indexPath: IndexPath, sender: UIButton) {
        
    }
    
}

extension HowToViewController: UITableViewDelegate {
    
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

extension HowToViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        cell.position = cells(position: tableView, indexPath: indexPath)
        cell.indexPath = indexPath
        cell.delegates = self
        
        cell.noteView.data = "\(indexPath)Take for example the TEXT type. It can contain 65535 bytes of data. Take for example the TEXT type. It can contain 65535 bytes of data."
        
        return cell
    }
    
}

