//
//  RecycleBinViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class RecycleBinViewController: UIViewController {
    
    @IBOutlet private var listView: UITableView!
    
    private let header = DRNoteCellHeader()
    let data = [["note0-1"], ["note1-1", "note1-2"], ["note2-1", "not2-2", "not2-3"], ["note4-1", "note4-2", "note4-3", "note4-4"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initView() {
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.contentInset.bottom = minSize * 0.3413
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 140
        
        header.frame.size.height = minSize * 0.2133
        listView.tableHeaderView = header
        let minimumRect = CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        listView.tableFooterView = UIView(frame: minimumRect)
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
    
}

extension RecycleBinViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let header = listView.tableHeaderView as? DRNoteCellHeader {
            let alpha = scrollView.contentOffset.y / header.contentView.titleLabel.frame.maxY
            guard let titleView = navigationItem.titleView else {return}
            UIView.animate(withDuration: 0.25) {
                titleView.alpha = (alpha < 0.8) ? 0 : 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return minSize * 0.1466
    }
    
}

extension RecycleBinViewController: UITableViewDataSource {
    
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
        return cell
    }
    
    /**
     TableView의 headerView에 대한 정의를 한다.
     - parameter tableView: 해당 headerView를 가지는 tableView.
     */
    private func table(viewHeaderView tableView: UITableView) {
        guard let header = tableView.tableHeaderView as? DRNoteCellHeader else {return}
        header.contentView.lockImage.isHidden = true
        header.contentView.titleLabel.text = "deletedMemo".locale
        header.contentView.newView.isHidden = true
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

