//
//  InteractViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class InteractViewController: UIViewController {
    
    @IBOutlet private var facebookLabel: UILabel!
    @IBOutlet private var facebookButton: UIButton!
    @IBOutlet private var listView: UITableView!
    
    private let header = DRNoteCellHeader()
    private var data = [String : [DRFBPosts]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        device(orientationDidChange: { _ in self.initConst()})
        initConst()
    }
    
    private func initView() {
        facebookLabel.font = UIFont.preferred(font: 23, weight: .bold)
        facebookLabel.text = "facebookNotice".locale
        facebookButton.titleLabel?.font = UIFont.preferred(font: 18, weight: .regular)
        facebookButton.layer.cornerRadius = 6
        
        let attr = NSMutableAttributedString(string: "")
        let attach = NSTextAttachment()
        attach.bounds.size = CGSize(width: 16.5, height: 16.5)
        attach.image = #imageLiteral(resourceName: "facebook")
        let image = NSAttributedString(attachment: attach)
        let str = NSAttributedString(string: "facebookLogin".locale)
        attr.append(image)
        attr.append(str)
        facebookButton.setAttributedTitle(attr, for: .normal)
        
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.contentInset.bottom = minSize * 0.3413
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 140
        
        header.frame.size.height = minSize * 0.2133
        listView.tableHeaderView = header
        let minimumRect = CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)
        listView.tableFooterView = UIView(frame: minimumRect)
        
        DRFBService.share.rxPost.subscribe {
            self.data = self.group(time: $0)
            self.listView.isHidden = false
            self.listView.reloadData()
        }
    }
    
    private func initConst() {
        makeConst(facebookLabel) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(0)
        }
        makeConst(facebookButton) {
            $0.leading.equalTo(self.minSize * 0.08)
            $0.trailing.equalTo(-(self.minSize * 0.08))
            $0.bottom.equalTo(-(self.minSize * 0.16))
            $0.height.equalTo(self.minSize * 0.1333)
        }
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
        if FBSDKAccessToken.current() != nil {
            DRFBService.share.facebook(post: "602234013303895")
        }
        navigationItem.titleView = makeView(UILabel()) {
            $0.font = UIFont.preferred(font: 17, weight: .semibold)
            $0.text = "deletedMemo".locale
            $0.alpha = 0
        }
    }()
    
}

// Login and data swiching 기능.
extension InteractViewController {
    
    @IBAction private func action(login: UIButton) {
        DRFBService.share.facebook(login: self) { success in
            if success {
                DRFBService.share.facebook(post: "602234013303895")
            }
        }
    }
    
    /**
     지정된 timeFormat에 따라 data를 grouping하여 반환한다.
     - parameter data: Non-grouped data.
     */
    private func group(time data: [DRFBPosts]) -> [String : [DRFBPosts]] {
        var result = [String : [DRFBPosts]]()
        for data in data {
            let key = timeFormat(data.updated)
            if result.keys.contains(key) {
                result[key]?.append(data)
            } else {
                result[key] = [data]
            }
        }
        return result
    }
    
}

extension InteractViewController: DRContentNoteDelegates {
    
    func select(indexPath: IndexPath) {
        
    }
    
}

extension InteractViewController: UITableViewDelegate {
    
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
        return minSize * 0.1333
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRNoteCellSection") as! DRNoteCellSection
        sections.sectionLabel.text = data[data.index(data.startIndex, offsetBy: section)].key
        return sections
    }
    
}

extension InteractViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[data.index(data.startIndex, offsetBy: section)].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        table(viewHeaderView: tableView)
        cell.delegates = self
        cell.indexPath = indexPath
        cell.position = cells(position: tableView, indexPath: indexPath)
        
        let dataIndex = data.index(data.startIndex, offsetBy: indexPath.section)
        let postData = data[dataIndex].value[indexPath.row]
        
        cell.noteView.dateLabel.text = ""
        if let updated = postData.updated {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            cell.noteView.dateLabel.text = formatter.string(from: updated)
        }
        cell.noteView.titleLabel.text = postData.name
        cell.noteView.contentLabel.text = postData.msg
        
        return cell
    }
    
    /**
     TableView의 headerView에 대한 정의를 한다.
     - parameter tableView: 해당 headerView를 가지는 tableView.
     */
    private func table(viewHeaderView tableView: UITableView) {
        guard let header = tableView.tableHeaderView as? DRNoteCellHeader else {return}
        header.contentView.lockImage.isHidden = true
        header.contentView.titleLabel.text = "interact".locale
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
