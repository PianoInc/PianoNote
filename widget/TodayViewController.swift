//
//  TodayViewController.swift
//  widget
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet private var listView: UITableView!
    @IBOutlet private var button: UIButton! { didSet {
        button.setTitle("newMemoSubText".locale, for: .normal)
        }}
    
    private var data = ["", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        initConst()
    }
    
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(minSize * 0.02)
            $0.trailing.equalTo(-(minSize * 0.02))
            $0.top.equalTo(minSize * 0.022)
            $0.bottom.equalTo(-(minSize * 0.12))
        }
        makeConst(button) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(self.listView.snp.bottom)
            $0.bottom.equalTo(0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // init data
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        preferredContentSize = maxSize
        if activeDisplayMode == .expanded {
            preferredContentSize.height = (minSize * 0.244 * CGFloat(data.count)) + (minSize * 0.12)
        }
        listView.reloadData()
    }
    
}

extension TodayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return minSize * ((extensionContext?.widgetActiveDisplayMode == .expanded) ? 0.244 : 0.14)
    }
    
}

extension TodayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DRTodayListCell") as! DRTodayListCell
        
        cell.folderLabel.text = "폴더_01"
        cell.timeLabel.text = "어제"
        cell.data = "\(indexPath)등산하는 사람들이 서로 부르거나, 외치는 소리. 주로 정상에서 외친다. 등산하는 사람들이 서로 부르거나, 외치는 소리. 주로 정상에서 외친다."
        cell.isExpanded = extensionContext?.widgetActiveDisplayMode == .expanded
        
        return cell
    }
    
}

class DRTodayListCell: UITableViewCell {
    
    @IBOutlet fileprivate var roundedView: UIView! { didSet {
        roundedView.layer.cornerRadius = 13
        }}
    @IBOutlet fileprivate var folderLabel: UILabel! { didSet {
        folderLabel.font = UIFont.preferred(font: 12.5, weight: .regular)
        }}
    @IBOutlet fileprivate var timeLabel: UILabel! { didSet {
        timeLabel.font = UIFont.preferred(font: 12.5, weight: .regular)
        }}
    @IBOutlet fileprivate var titleLabel: UILabel! { didSet {
        titleLabel.font = UIFont.preferred(font: 14.2, weight: .semibold)
        }}
    @IBOutlet fileprivate var contentLabel: UILabel! { didSet {
        contentLabel.font = UIFont.preferred(font: 15.2, weight: .regular)
        }}
    
    fileprivate var data = "" { didSet {
        continuousText()
        }}
    fileprivate var isExpanded = true
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initConst()
    }
    
    private func initConst() {
        makeConst(roundedView) {
            $0.leading.equalTo(0)
            $0.trailing.equalTo(0)
            $0.top.equalTo(0)
            $0.bottom.equalTo(-(minSize * 0.02))
        }
        makeConst(timeLabel) {
            $0.trailing.equalTo(-(minSize * 0.0306))
            $0.top.equalTo(minSize * 0.0346)
        }
        makeConst(folderLabel) {
            $0.leading.equalTo(minSize * 0.0306)
            $0.trailing.equalTo(self.timeLabel.snp.leading)
            $0.top.equalTo(minSize * 0.0346)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        continuousText()
        updateShape()
    }
    
    /// titleLabel과 contentLabel의 Text가 하나의 문장으로 이어지도록 만든다.
    private func continuousText() {
        titleLabel.text = data
        let firstLineText = titleLabel.firstLineText
        titleLabel.text = firstLineText
        contentLabel.text = data.sub(firstLineText.count...)
    }
    
    /// 위젯 mode에 따라 cell의 모습을 바꾼다.
    private func updateShape() {
        timeLabel.isHidden = !isExpanded
        folderLabel.isHidden = !isExpanded
        makeConst(contentLabel) {
            $0.leading.equalTo(minSize * 0.0306)
            $0.trailing.equalTo(-(minSize * 0.0306))
            let offset: CGFloat = self.isExpanded ? 0.036 : 0.013
            $0.bottom.equalTo(self.roundedView.snp.bottom).offset(-(minSize * offset))
        }
        makeConst(titleLabel) {
            $0.leading.equalTo(minSize * 0.0306)
            $0.trailing.equalTo(-(minSize * 0.0306))
            $0.bottom.equalTo(self.contentLabel.snp.top).offset(-(minSize * 0.012))
        }
    }
    
}

