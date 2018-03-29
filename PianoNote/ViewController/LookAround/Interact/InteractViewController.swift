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
        listView.contentInset.bottom = minSize * 0.3413
        listView.initHeaderView(minSize * 0.2133)
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 140
        }}
    
    private var data = [[String : [DRFBPost]]]()
    
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
        if FBSDKAccessToken.current() != nil {requestLoad()}
        navigationItem.titleView = makeView(UILabel()) {
            $0.font = UIFont.preferred(font: 17, weight: .semibold)
            $0.text = "interact".locale
            $0.alpha = 0
        }
    }()
    
}

// Login and data 기능.
extension InteractViewController {
    
    @IBAction private func action(login: UIButton) {
        DRFBService.share.facebook(login: self) {
            if $0 {self.requestLoad()}
        }
    }
    
    /// Post data의 load를 요청한다.
    private func requestLoad(_ postID: String = "602234013303895") {
        self.facebookLabel.isHidden = true
        self.facebookButton.isHidden = true
        DRFBService.share.facebook(post: postID)
        DRFBService.share.rxPost.subscribe {
            self.data = self.group(time: $0)
            self.listView.isHidden = false
            self.listView.reloadData()
        }
    }
    
    /**
     지정된 timeFormat에 따라 data를 grouping하여 반환한다.
     - parameter data: Non-grouped data.
     */
    private func group(time data: [DRFBPost]) -> [[String : [DRFBPost]]] {
        var result = [[String : [DRFBPost]]]()
        for data in data {
            let key = data.create.timeFormat
            if result.contains(where: {$0.contains {$0.0 == key}}) {
                let idx = result.index(where: {$0.contains {$0.0 == key}})!
                result[idx][key]?.append(data)
            } else {
                result.append([key : [data]])
            }
        }
        return result
    }
    
}

extension InteractViewController: DRContentNoteDelegates {
    
    func select(indexPath: IndexPath) {
        DRFBService.share.facebook(comment: post(data: indexPath).id)
        DRFBService.share.rxComment.subscribe { data in
            let viewContoller = UIStoryboard.view(type: InteractDetailViewController.self)
            viewContoller.postTitle = self.post(data: indexPath).title
            viewContoller.data = data
            self.present(view: viewContoller)
        }
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
        
        sections.sectionLabel.text = data[section].first!.key
        
        return sections
    }
    
}

extension InteractViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].first!.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRContentNoteCell") as! DRContentNoteCell
        cell.position = cells(position: tableView, indexPath: indexPath)
        cell.indexPath = indexPath
        cell.delegates = self
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        cell.noteView.dateLabel.text = formatter.string(from: post(data: indexPath).create)
        cell.noteView.data = post(data: indexPath).msg
        
        return cell
    }
    
    /**
     해당 indexPath에 맞는 data를 반환한다.
     - parameter indexPath: 찾고자 하는 indexPath.
     */
    private func post(data indexPath: IndexPath) -> DRFBPost {
        return data[indexPath.section].first!.value[indexPath.row]
    }
    
}

