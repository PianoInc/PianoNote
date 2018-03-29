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
    
    @IBOutlet private var facebookLabel: UILabel! {
        didSet {
            facebookLabel.font = UIFont.preferred(font: 23, weight: .bold)
            facebookLabel.text = "facebookNotice".locale
        }
    }
    @IBOutlet private var facebookButton: UIButton! {
        didSet {
            facebookButton.layer.cornerRadius = 6
            facebookButton.titleLabel?.font = UIFont.preferred(font: 18, weight: .regular)
            let attr = NSMutableAttributedString(string: "")
            let attach = NSTextAttachment()
            attach.bounds.size = CGSize(width: 16.5, height: 16.5)
            attach.image = #imageLiteral(resourceName: "facebook")
            attr.append(NSAttributedString(attachment: attach))
            attr.append(NSAttributedString(string: "facebookLogin".locale))
            facebookButton.setAttributedTitle(attr, for: .normal)
        }
    }
    @IBOutlet private var listView: UITableView! {
        didSet {
            listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
            listView.contentInset.bottom = minSize * 0.3413
            listView.initHeaderView(minSize * 0.2133)
            listView.rowHeight = UITableViewAutomaticDimension
            listView.estimatedRowHeight = 140
        }
    }
    
    private var data = [String : [DRFBPosts]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
    }
    
    private func initConst() {
        func constraint() {
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
        constraint()
        device(orientationDidChange: { _ in constraint()})
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
        DRFBService.share.rxPost.subscribe {
            self.data = self.group(time: $0)
            self.listView.isHidden = false
            self.listView.reloadData()
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
        DRFBService.share.facebook(login: self) {
            if $0 {DRFBService.share.facebook(post: "602234013303895")}
        }
    }
    
    /**
     지정된 timeFormat에 따라 data를 grouping하여 반환한다.
     - parameter data: Non-grouped data.
     */
    private func group(time data: [DRFBPosts]) -> [String : [DRFBPosts]] {
        var result = [String : [DRFBPosts]]()
        for data in data {
            let key = data.updated?.timeFormat ?? ""
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
        naviTitleShowing(scrollView)
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
        cell.position = cells(position: tableView, indexPath: indexPath)
        cell.indexPath = indexPath
        cell.delegates = self
        
        let dataIndex = data.index(data.startIndex, offsetBy: indexPath.section)
        let postData = data[dataIndex].value[indexPath.row]
        
        cell.noteView.dateLabel.text = ""
        if let updated = postData.updated {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            cell.noteView.dateLabel.text = formatter.string(from: updated)
        }
        cell.noteView.data = postData.msg
        
        return cell
    }
    
}

