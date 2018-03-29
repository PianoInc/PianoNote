//
//  InteractDetailViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class InteractDetailViewController: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel! { didSet {
        titleLabel.font = UIFont.preferred(font: 23, weight: .bold)
        }}
    @IBOutlet private var listView: UITableView!
    
    var data = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "존경하는 아이폰 유저님들! 평소에 메모앱에다가 무엇을 적으시나요?"
        initConst()
    }
    
    private func initConst() {
        func constraint() {
            makeConst(titleLabel) {
                $0.leading.equalTo(self.safeInset.left + self.minSize * 0.1093).priority(.high)
                $0.trailing.equalTo(-(self.safeInset.right + self.minSize * 0.1093)).priority(.high)
                $0.top.equalTo(self.statusHeight + self.naviHeight + self.minSize * 0.064).priority(.high)
                $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
                $0.centerX.equalToSuperview().priority(.required)
            }
            makeConst(listView) {
                $0.leading.equalTo(self.safeInset.left).priority(.high)
                $0.trailing.equalTo(-self.safeInset.right).priority(.high)
                $0.top.equalTo(self.titleLabel.snp.bottom).offset(self.minSize * 0.064).priority(.high)
                $0.bottom.equalTo(-self.safeInset.bottom).priority(.high)
                $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
                $0.centerX.equalToSuperview().priority(.required)
            }
        }
        constraint()
        device(orientationDidChange: { _ in constraint()})
    }
    
}

extension InteractDetailViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let alpha = scrollView.contentOffset.y / titleLabel.frame.maxY
        guard let titleView = navigationItem.titleView else {return}
        UIView.animate(withDuration: 0.25) {
            titleView.alpha = (alpha < 0.8) ? 0 : 1
        }
    }
    
}

extension InteractDetailViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRDetailCommentCell") as! DRDetailCommentCell
        return cell
    }
    
}

