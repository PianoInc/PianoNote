//
//  InteractDetailViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class InteractDetailViewController: DRViewController {
    
    @IBOutlet private var listView: UITableView! { didSet {
        listView.register(DRDetailCommentSection.self, forHeaderFooterViewReuseIdentifier: "DRDetailCommentSection")
        listView.initHeaderView(minSize * 0.2666)
        listView.sectionHeaderHeight = UITableViewAutomaticDimension
        listView.rowHeight = UITableViewAutomaticDimension
        }}
    
    var postData = (id : "", title : "")
    
    private var estimatedHeaderHeight = [Int : CGFloat]()
    private var estimatedCellHeight = [IndexPath : CGFloat]()
    private var data = [DRFBComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
        attachData()
        DRFBService.share.facebook(comment: postData.id)
    }
    
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(self.safeInset.left)
            $0.trailing.equalTo(-self.safeInset.right)
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
        listView.headerView(multiLine: postData.title)
        navigationItem.titleView = makeView(UILabel()) {
            $0.font = UIFont.preferred(font: 17, weight: .semibold)
            $0.text = postData.title
            $0.alpha = 0
        }
    }()
    
    /// Data의 변화를 감지하여 listView에 이어 붙인다.
    private func attachData() {
        DRFBService.share.rxComment.subscribe { [weak self] data in
            data.forEach {self?.data.append($0)}
            self?.listView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self?.listView.alpha = 1
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(hex6: "EAEBED")
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        navigationController?.navigationBar.barTintColor = UIColor(hex6: "F9F9F9")
        DRFBService.share.resetComment()
    }
    
}

extension InteractDetailViewController: DRDetailDelegates {
    
    func extend(reply indexPath: IndexPath) {
        guard !data[indexPath.section].expend else {return}
        data[indexPath.section].expend = true
        listView.reloadData()
    }
    
}

extension InteractDetailViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fadeNavigationTitle(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        requestNextData(scrollView) {
            DRFBService.share.facebook(comment: postData.id)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        estimatedHeaderHeight[section] = view.bounds.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        estimatedCellHeight[indexPath] = cell.bounds.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return estimatedHeaderHeight[section] ?? 108
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedCellHeight[indexPath] ?? 108
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRDetailCommentSection") as! DRDetailCommentSection
        view.indexPath = IndexPath(row: 0, section: section)
        view.delegates = self
        
        view.nameLabel.text = "이름"
        view.contentLabel.text = data[section].msg
        view.timeLabel.text = data[section].create.timeFormat
        
        view.replyButton.isEnabled = false
        view.replyButton.setTitle("facebookNoReply".locale, for: .normal)
        if data[section].count > 0 {
            view.replyButton.isEnabled = true
            let replyText = String(format: "facebookReply".locale, data[section].count)
            view.replyButton.setTitle(replyText, for: .normal)
        }
        
        return view
    }
    
}

extension InteractDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].expend ? (data[section].reply?.count ?? 0) : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRDetailReplyCell") as! DRDetailReplyCell
        
        guard let data = comment(data: indexPath) else {return cell}
        cell.nameLabel.text = "이름" + " "
        cell.contentLabel.text = cell.nameLabel.text! + data.msg
        cell.timeLabel.text = data.create.timeFormat
        
        return cell
    }
    
    /**
     해당 indexPath에 맞는 data를 반환한다.
     - parameter indexPath: 찾고자 하는 indexPath.
     */
    private func comment(data indexPath: IndexPath) -> DRFBReply? {
        return data[indexPath.section].reply?[indexPath.row]
    }
    
}

