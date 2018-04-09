//
//  InteractViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

// Facebook piano page ID
let PianoPageID = "602234013303895"

class InteractViewController: DRViewController {
    
    @IBOutlet private var facebookLabel: UILabel! { didSet {
        facebookLabel.font = UIFont.preferred(font: 23, weight: .bold)
        facebookLabel.text = "facebookNotice".locale
        }}
    @IBOutlet private var facebookButton: UIButton! { didSet {
        facebookButton.layer.cornerRadius = 6
        facebookButton.titleLabel?.font = UIFont.preferred(font: 18, weight: .regular)
        let attr = NSMutableAttributedString(string: "")
        let attach = NSTextAttachment()
        attach.bounds.size = CGSize(width: 16.5, height: 16.5)
        attach.image = #imageLiteral(resourceName: "facebook")
        attr.append(NSAttributedString(attachment: attach))
        attr.append(NSAttributedString(string: "facebookLogin".locale))
        facebookButton.setAttributedTitle(attr, for: .normal)
        }}
    @IBOutlet private var listView: UITableView! { didSet {
        listView.register(DRNoteCellSection.self, forHeaderFooterViewReuseIdentifier: "DRNoteCellSection")
        listView.initHeaderView(minSize * 0.2133)
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 140
        }}
    
    private var data = [[String : [DRFBPost]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
        attachData()
        if FBSDKAccessToken.current() != nil {
            DRFBService.share.facebook(post: PianoPageID)
        } else {
            self.facebookLabel.isHidden = false
            self.facebookButton.isHidden = false
        }
    }
    
    @IBAction private func action(login: UIButton) {
        DRFBService.share.facebook(login: self) {
            guard $0 == true else {return}
            self.facebookLabel.isHidden = true
            self.facebookButton.isHidden = true
            DRFBService.share.facebook(post: PianoPageID)
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
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        navigationItem.titleView = makeView(UILabel()) {
            $0.font = UIFont.preferred(font: 17, weight: .semibold)
            $0.text = "interact".locale
            $0.alpha = 0
        }
    }()
    
    /// Data의 변화를 감지하여 listView에 이어 붙인다.
    private func attachData() {
        DRFBService.share.rxPost.subscribe {
            self.group(time: $0)
            self.listView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.listView.alpha = 1
            }
        }
    }
    
    /**
     지정된 timeFormat에 따라 data를 grouping한다.
     - parameter data: Non-grouped data.
     */
    private func group(time data: [DRFBPost]) {
        for post in data {
            let key = post.create.timeFormat
            if self.data.contains(where: {$0.contains {$0.0 == key}}) {
                if let idx = self.data.index(where: {$0.contains {$0.0 == key}}) {
                    self.data[idx][key]?.append(post)
                }
            } else {
                self.data.append([key : [post]])
            }
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        DRFBService.share.resetPost()
    }
    
}

extension InteractViewController: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        requestNextData(scrollView) {
            DRFBService.share.facebook(post: "602234013303895")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fadeNavigationTitle(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return minSize * 0.1333
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRNoteCellSection") as! DRNoteCellSection
        sections.sectionLabel.text = data[section].first!.key
        return sections
    }
    
}

extension InteractViewController: UITableViewDataSource, DRContentNoteDelegates {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].first?.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        cell.position = cells(position: tableView, indexPath: indexPath)
        cell.indexPath = indexPath
        cell.delegates = self
        
        guard let data = post(data: indexPath) else {return cell}
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        cell.noteView.dateLabel.text = formatter.string(from: data.create)
        cell.noteView.data = data.msg
        
        return cell
    }
    
    /**
     해당 indexPath에 맞는 data를 반환한다.
     - parameter indexPath: 찾고자 하는 indexPath.
     */
    private func post(data indexPath: IndexPath) -> DRFBPost? {
        return data[indexPath.section].first?.value[indexPath.row]
    }
    
    func select(indexPath: IndexPath) {
        guard let postData = post(data: indexPath) else {return}
        let viewContoller = UIStoryboard.view(type: InteractDetailViewController.self)
        viewContoller.postData = (id: postData.id, title: postData.title)
        self.present(view: viewContoller)
    }
    
}

