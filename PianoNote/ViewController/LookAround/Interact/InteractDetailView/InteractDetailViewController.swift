//
//  InteractDetailViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class InteractDetailViewController: UIViewController {
    
    @IBOutlet private var listView: UITableView! { didSet {
        listView.register(DRDetailCommentSection.self, forHeaderFooterViewReuseIdentifier: "DRDetailCommentSection")
        listView.initHeaderView(minSize * 0.2666)
        listView.sectionHeaderHeight = UITableViewAutomaticDimension
        listView.estimatedSectionHeaderHeight = 140
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 140
        }}
    
    var postData = (id : "", title : "")
    private var data = [DRFBComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
        DRFBService.share.rxComment.subscribe {
            $0.forEach {self.data.append($0)}
            self.listView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.listView.alpha = 1
            }
        }
        DRFBService.share.facebook(comment: postData.id)
    }
    
    private func initConst() {
        func constraint() {
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
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        // DetailView에서는 기존의 모습과 다른 모습이라 titleLabel을 재정의 한다.
        if let headerView = listView.tableHeaderView as? DRNoteCellHeader {
            headerView.contentView.subviews.forEach {$0.isHidden = true}
            headerView.contentView.titleLabel.isHidden = false
            headerView.contentView.titleLabel.numberOfLines = 2
            headerView.contentView.titleLabel.font = UIFont.preferred(font: 23, weight: .bold)
            makeConst(headerView.contentView.titleLabel) {
                $0.leading.equalTo(self.minSize * 0.1066)
                $0.trailing.equalTo(-(self.minSize * 0.1066))
                $0.top.equalTo(self.minSize * 0.0666)
                $0.bottom.equalTo(-(self.minSize * 0.0666))
            }
            headerView.contentView.titleLabel.text = postData.title
        }
        navigationItem.titleView = makeView(UILabel()) {
            $0.font = UIFont.preferred(font: 17, weight: .semibold)
            $0.text = postData.title
            $0.alpha = 0
        }
    }()
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        DRFBService.share.resetComment()
    }
    
}

extension InteractDetailViewController: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if  currentOffset / maximumOffset > 0.9 {
            DRFBService.share.facebook(comment: postData.id)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        naviTitleShowing(scrollView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRDetailCommentSection") as! DRDetailCommentSection
        
        view.nameLabel.text = "이름"
        view.contentLabel.text = data[section].msg
        view.timeLabel.text = data[section].create.timeFormat
        view.replyLabel.text = "답글 없음"
        if data[section].count > 0 {
            view.replyLabel.text = "답글 \(data[section].count)개"
        }
        
        return view
    }
    
}

extension InteractDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].reply?.count ?? 0
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

