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
        listView.contentInset.bottom = minSize * 0.3413
        listView.initHeaderView(minSize * 0.2666)
        listView.sectionHeaderHeight = UITableViewAutomaticDimension
        listView.estimatedSectionHeaderHeight = 100
        listView.rowHeight = UITableViewAutomaticDimension
        listView.estimatedRowHeight = 100
        }}
    
    var data = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
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
        device(orientationDidChange: { _ in constraint()})
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
            headerView.contentView.titleLabel.text = "존경하는 아이폰 유저님들! 평소에 메모앱에다가 무엇을 적으시나요?"
        }
        // TableView의 section auto layout을 적용하기 위한 코드.
        listView.beginUpdates()
        listView.endUpdates()
        navigationItem.titleView = makeView(UILabel()) {
            $0.font = UIFont.preferred(font: 17, weight: .semibold)
            $0.text = "존경하는 아이폰 유저님들! 평소에 메모앱에다가 무엇을 적으시나요?"
            $0.alpha = 0
        }
    }()
    
}

extension InteractDetailViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        naviTitleShowing(scrollView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DRDetailCommentSection") as! DRDetailCommentSection
        view.nameLabel.text = "박요진"
        view.contentLabel.text = "보통 메모를 하거나 일기를 쓰는데 일년 전 글이 다시 올라오는게 있으면 좋을 것 같아요!"
        view.replyLabel.text = "답글 1개"
        view.timeLabel.text = "30분 전"
        return view
    }
    
}

extension InteractDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRDetailReplyCell") as! DRDetailReplyCell
        cell.nameLabel.text = "Soyeon Shin"
        cell.contentLabel.text = "Soyeon Shin 메모앱에서 그림그리는 건 정말 기본적이라서 불편한데 그 중에서도 브러쉬 크기를 못 바꾸는 게 제일 불편해요ㅠㅠ 그리고 메모 잠금하면 내용 찾기가 안되는 것도 불편하구요..."
        cell.replyLabel.text = "답글 2개"
        cell.timeLabel.text = "1시간 전"
        return cell
    }
    
}

