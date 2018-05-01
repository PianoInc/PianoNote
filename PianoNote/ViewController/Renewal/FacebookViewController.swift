//
//  FacebookViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 1..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FBSDKCoreKit

class FacebookViewController: DRViewController {
    
    @IBOutlet private var facebookLabel: UILabel! { didSet {
        facebookLabel.font = UIFont.preferred(font: 23, weight: .bold)
        facebookLabel.text = "facebookNotice".locale
        }}
    @IBOutlet private var facebookButton: UIButton! { didSet {
        facebookButton.corner(rad: 6)
        facebookButton.titleLabel?.font = UIFont.preferred(font: 18, weight: .regular)
        let attr = NSMutableAttributedString(string: "")
        let attach = NSTextAttachment()
        attach.bounds.size = CGSize(width: 16.5, height: 16.5)
        attach.image = #imageLiteral(resourceName: "facebook")
        attr.append(NSAttributedString(attachment: attach))
        attr.append(NSAttributedString(string: "facebookLogin".locale))
        facebookButton.setAttributedTitle(attr, for: .normal)
        }}
    
    private let nodeCtrl = FacebookNodeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nodeCtrl.isHidden = true
        view.addSubnode(nodeCtrl)
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
        attachData()
        
        if FBSDKAccessToken.current() != nil {
            DRFBService.share.facebook(post: PianoPageID)
        } else {
            facebookLabel.isHidden = false
            facebookButton.isHidden = false
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
            $0.leading.equalTo(self.minSize * 0.08).priority(.high)
            $0.trailing.equalTo(-(self.minSize * 0.08)).priority(.high)
            $0.bottom.equalTo(-(self.minSize * 0.16))
            $0.height.equalTo(self.minSize * 0.1333)
            $0.width.lessThanOrEqualTo(self.limitWidth).priority(.required)
            $0.centerX.equalToSuperview().priority(.required)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nodeCtrl.frame = view.frame
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        DRFBService.share.resetPost()
    }
    
    /// Data의 변화를 감지하여 listView에 이어 붙인다.
    private func attachData() {
        DRFBService.share.rxPost.subscribe { [weak self] data in
            self?.nodeCtrl.isHidden = false
            self?.group(time: data)
        }
    }
    
    /**
     지정된 timeFormat에 따라 data를 grouping한다.
     - parameter data: Non-grouped data.
     */
    private func group(time data: [DRFBPost]) {
        for post in data {
            let key = post.create.timeFormat
            if nodeCtrl.data.contains(where: {$0.contains {$0.0 == key}}) {
                if let idx = nodeCtrl.data.index(where: {$0.contains {$0.0 == key}}) {
                    nodeCtrl.data[idx][key]?.append(post)
                    let indexPath = IndexPath(row: nodeCtrl.data[idx][key]!.count - 1, section: idx)
                    nodeCtrl.listNode.insertItems(at: [indexPath])
                }
            } else {
                nodeCtrl.data.append([key : [post]])
                let indexSet = IndexSet(integer: nodeCtrl.data.count - 1)
                nodeCtrl.listNode.insertSections(indexSet)
            }
        }
    }
    
    @IBAction private func action(login: UIButton) {
        DRFBService.share.facebook(login: self) {
            guard $0 else {return}
            self.facebookLabel.isHidden = true
            self.facebookButton.isHidden = true
            DRFBService.share.facebook(post: PianoPageID)
        }
    }
    
}

class FacebookNodeController: ASDisplayNode {
    
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var data = [[String : [DRFBPost]]]()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 0
        listNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        listNode.view.alwaysBounceVertical = true
        listNode.allowsSelection = false
        listNode.layoutInspector = self
        listNode.dataSource = self
        listNode.delegate = self
        
        initListGesture()
    }
    
    private func initListGesture() {
        ASMainSerialQueue().performBlock {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.action(tap:)))
            self.listNode.view.addGestureRecognizer(tap)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: safeArea(from: constrainedSize.max.width), child: listNode)
    }
    
    @objc private func action(tap: UITapGestureRecognizer) {
        let point = tap.location(in: listNode.view)
        guard let _ = listNode.indexPathForItem(at: point) else {return}
        
    }
    
}

extension FacebookNodeController: ASCollectionViewLayoutInspecting {
    
    func scrollableDirections() -> ASScrollDirection {
        return .down
    }
    
    func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
        return (kind == UICollectionElementKindSectionHeader) ? 1 : 0
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 60.auto))
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
}

extension FacebookNodeController: ASCollectionDelegate, ASCollectionDataSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        guard currentOffset / maximumOffset > 0.9 else {return}
        DRFBService.share.facebook(post: "602234013303895")
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return data.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return data[section].first?.value.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            let facebookSectionNode = FacebookSectionNode()
            guard !self.data.isEmpty else {return facebookSectionNode}
            facebookSectionNode.title = self.data[indexPath.section].first!.key
            return facebookSectionNode
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            let facebookRowNode = FacebookRowNode()
            guard let data = self.post(data: indexPath) else {return facebookRowNode}
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            facebookRowNode.date = formatter.string(from: data.create)
            facebookRowNode.content = data.msg
            facebookRowNode.place = self.node(place: indexPath)
            return facebookRowNode
        }
    }
    
    /**
     해당 cell의 indexPath에 부합하는 data를 반환한다.
     - parameter indexPath: 찾고자 하는 indexPath.
     - returns : 해상 indexPath에 부합하는 data값.
     */
    private func post(data indexPath: IndexPath) -> DRFBPost? {
        return data[indexPath.section].first?.value[indexPath.row]
    }
    
    /**
     해당 indexPath의 node가 section내 어디에 위치하는지를 판별한다.
     - parameter indexPath: Node의 indexPath값.
     */
    private func node(place indexPath: IndexPath) -> NodePlace {
        if listNode.numberOfItems(inSection: indexPath.section) == 1 {
            return .single
        } else if indexPath.row == 0 {
            return .top
        } else if indexPath.row == listNode.numberOfItems(inSection: indexPath.section) - 1 {
            return .bottom
        }
        return .middle
    }
        
}

class FacebookSectionNode: ASCellNode {
    
    fileprivate let titleNode = ASTextNode()
    
    fileprivate var title = ""
    fileprivate var isHeader: Bool {
        return indexPath?.section == 0
    }
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.isLayerBacked = true
    }
    
    override func didLoad() {
        super.didLoad()
        let font = UIFont.systemFont(ofSize: isHeader ? 34.auto : 23.auto, weight: .bold)
        titleNode.attributedText = NSAttributedString(string: "title", attributes: [.font : font])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        titleCenter.style.preferredSize = constrainedSize.max
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: isHeader ? 24.auto : 31.auto), child: titleCenter)
        return titleInset
    }
    
}

class FacebookRowNode: ASCellNode {
    
    fileprivate let backgroundNode = ASDisplayNode()
    fileprivate let foregroundNode = ASDisplayNode()
    fileprivate let dateNode = ASTextNode()
    fileprivate let titleNode = ASTextNode()
    fileprivate let contentNode = ASTextNode()
    
    fileprivate var place = NodePlace.single
    fileprivate var date = ""
    fileprivate var content = ""
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        backgroundNode.backgroundColor = UIColor(hex6: "eaebed")
        backgroundNode.isLayerBacked = true
        backgroundNode.cornerRadius = 14
        
        foregroundNode.backgroundColor = .white
        foregroundNode.isLayerBacked = true
        foregroundNode.cornerRadius = 10
        foregroundNode.borderColor = UIColor(hex6: "b5b5b5").cgColor
        foregroundNode.borderWidth = 0.5
        
        dateNode.maximumNumberOfLines = 1
        dateNode.isLayerBacked = true
        
        titleNode.maximumNumberOfLines = 1
        titleNode.isLayerBacked = true
        
        contentNode.isLayerBacked = true
    }
    
    override func didLoad() {
        super.didLoad()
        let folderFont = UIFont.systemFont(ofSize: 13.5.auto)
        dateNode.attributedText = NSAttributedString(string: date, attributes: [.font : folderFont])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let folderInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 14.auto, l: 15.5.auto, r: 15.5.auto), child: dateNode)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 8.auto, l: 15.5.auto, b: 8.auto, r: 15.5.auto), child: titleNode)
        let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 15.5.auto, b: 14.auto, r: 15.5.auto), child: contentNode)
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.style.preferredLayoutSize = ASLayoutSize(width: ASDimension.init(unit: .points, value: constrainedSize.max.width), height: ASDimensionAuto)
        vStack.children = [folderInset, titleInset, contentInset]
        
        let foreOver = ASBackgroundLayoutSpec(child: vStack, background: foregroundNode)
        let foreInset = ASInsetLayoutSpec(insets: shapeInset().fore, child: foreOver)
        
        let backOver = ASBackgroundLayoutSpec(child: foreInset, background: backgroundNode)
        let backInset = ASInsetLayoutSpec(insets: shapeInset().back, child: backOver)
        
        return backInset
    }
    
    private func shapeInset() -> (fore: UIEdgeInsets, back: UIEdgeInsets) {
        var fore = UIEdgeInsets(t: 6.auto, l: 6.auto, b: 6.auto, r: 6.auto)
        var back = UIEdgeInsets(l: 12.5.auto, r: 12.5.auto)
        let offset = backgroundNode.cornerRadius * 2
        if place == .top {
            fore.bottom = offset + 3
            back.bottom = -offset
        } else if place == .middle {
            fore.top = offset + 3
            back.top = -offset
            fore.bottom = offset + 3
            back.bottom = -offset
        } else if place == .bottom {
            fore.top = offset + 3
            back.top = -offset
        }
        return (fore: fore, back: back)
    }
    
    override func layout() {
        super.layout()
        continuousText()
    }
    
    private func continuousText() {
        let titleFont = UIFont.systemFont(ofSize: 29.2.auto, weight: .bold)
        let titleAttStr = NSAttributedString(string: content, attributes: [.font : titleFont])
        titleNode.attributedText = titleAttStr.firstLine(width: titleNode.frame.width)
        
        let contentText = titleAttStr.string.sub(titleNode.attributedText!.length...)
        let contentFont = UIFont.systemFont(ofSize: 16.8.auto)
        contentNode.attributedText = NSAttributedString(string: contentText, attributes: [.font : contentFont])
    }
    
}

