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
        }}
    
    private var sectionHeight = [Int : CGFloat]()
    private var cellHeight = [IndexPath : CGFloat]()
    private var data = [DRFBComment]()
    
    var postData = (id : "", title : "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
        attachData()
        DRFBService.share.facebook(comment: postData.id)
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight[section] ?? height(header: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight[section] ?? height(header: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard view.bounds.height > 0 else {return}
        sectionHeight[section] = view.bounds.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRDetailCommentSection") as! DRDetailCommentSection
        view.indexPath = IndexPath(row: 0, section: section)
        view.delegates = self
        
        view.nameLabel.text = "댓글 작성자"
        view.contentLabel.text = data[section].msg
        view.timeLabel.text = data[section].create.timeFormat
        
        view.replyButton.isEnabled = (!data[section].expend && data[section].count > 0)
        view.replyButton.setTitle("facebookNoReply".locale, for: .normal)
        if data[section].count > 0 {
            let replyText = String(format: "facebookReply".locale, data[section].count)
            view.replyButton.setTitle(replyText, for: .normal)
        }
        
        return view
    }
    
    /**
     해당 header의 section값에 부합하는 msg가 가지는 boundingRect의 height값을 반환한다.
     - parameter section: 계산하고자 하는 section값.
     - returns : msg가 가지는 height값.
     */
    private func height(header section: Int) -> CGFloat {
        guard !data.isEmpty else {return 0}
        let width = UIDevice.current.userInterfaceIdiom == .phone ? minSize * 0.8888 : limitWidth
        let height = data[section].msg.boundingRect(with: width, font: 15)
        let inset = minSize * 0.2133
        return height + inset
    }
    
}

extension InteractDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].reply?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight[indexPath] ?? height(cell: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight[indexPath] ?? height(cell: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard cell.bounds.height > 0 else {return}
        cellHeight[indexPath] = cell.bounds.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRDetailReplyCell") as! DRDetailReplyCell
        
        guard let data = comment(data: indexPath) else {return cell}
        cell.nameLabel.text = "답글 작성자 " + " "
        cell.contentLabel.text = "답글 작성자 " + data.msg
        cell.timeLabel.text = data.create.timeFormat
        
        return cell
    }
    
    /**
     해당 indexPath에 부합하는 data를 반환한다.
     - parameter indexPath: 찾고자 하는 indexPath.
     */
    private func comment(data indexPath: IndexPath) -> DRFBReply? {
        return data[indexPath.section].reply?[indexPath.row]
    }
    
    /**
     해당 cell의 indexPath에 부합하는 msg가 가지는 boundingRect의 height값을 반환한다.
     - parameter indexPath: 계산하고자 하는 indexPath.
     - returns : msg가 가지는 height값.
     */
    private func height(cell indexPath: IndexPath) -> CGFloat {
        guard let msg = comment(data: indexPath)?.msg else {return 0}
        let width = UIDevice.current.userInterfaceIdiom == .phone ? minSize * 0.7004 : limitWidth
        let height = ("답글 작성자 " + msg).boundingRect(with: width, font: 14)
        let inset = minSize * 0.1631
        return data[indexPath.section].expend ? height + inset : 0
    }
    
}

