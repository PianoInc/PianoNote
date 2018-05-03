//
//  FacebookDetailViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 1..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FacebookDetailViewController: DRViewController {
    
    private let nodeCtrl = FacebookDetailNodeController()
    
    var postData = (id : "", title : "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nodeCtrl.postData = postData
        view.addSubnode(nodeCtrl)
        attachData()
        DRFBService.share.facebook(comment: postData.id)
    }
    
    /// Data의 변화를 감지하여 listView에 이어 붙인다.
    private func attachData() {
        DRFBService.share.rxComment.subscribe { [weak self] data in
            data.enumerated().forEach {
                self?.nodeCtrl.data.append($1)
                self?.nodeCtrl.listNode.insertSections(IndexSet(integer: $0))
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nodeCtrl.frame = view.frame
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        DRFBService.share.resetComment()
    }
    
}

class FacebookDetailNodeController: ASDisplayNode, FBDetailSectionDelegates {
    
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate let facebookNode = ASButtonNode()
    
    fileprivate var postData = (id : "", title : "")
    fileprivate var data = [DRFBComment]()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 0
        listNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        listNode.backgroundColor = .clear
        listNode.view.alwaysBounceVertical = true
        listNode.contentInset.top = 16.fit
        listNode.allowsSelection = false
        listNode.layoutInspector = self
        listNode.dataSource = self
        listNode.delegate = self
        
        facebookNode.setImage(#imageLiteral(resourceName: "info"), for: .normal)
        let facebookFont = UIFont.systemFont(ofSize: 16.fit)
        facebookNode.setAttributedTitle(NSAttributedString(string: "facebookVisit".locale, attributes: [.font : facebookFont, .foregroundColor : UIColor(hex6: "007aff")]), for: .normal)
        facebookNode.addTarget(self, action: #selector(action(facebook:)), forControlEvents: .touchUpInside)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        listNode.style.flexGrow = 1
        facebookNode.style.flexShrink = 0
        facebookNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimension(unit: .points, value: 45.fit))
        let vStack = ASStackLayoutSpec.vertical()
        vStack.children = [listNode, facebookNode]
        return ASInsetLayoutSpec(insets: safeArea(from: constrainedSize.max.width), child: vStack)
    }
    
    func expand(indexPath: IndexPath) {
        data[indexPath.section].expend = true
        listNode.reloadSections(IndexSet(integer: indexPath.section))
    }
    
    @objc private func action(facebook: ASButtonNode) {
        let url = URL(string: "https://www.facebook.com/pg/OurLovePiano/posts")!
        guard UIApplication.shared.canOpenURL(url) else {return}
        UIApplication.shared.open(url)
    }
    
}

extension FacebookDetailNodeController: ASCollectionViewLayoutInspecting {
    
    func scrollableDirections() -> ASScrollDirection {
        return .down
    }
    
    func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
        return (kind == UICollectionElementKindSectionHeader) ? 1 : 0
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
}

extension FacebookDetailNodeController: ASCollectionDelegate, ASCollectionDataSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        guard currentOffset / maximumOffset > 0.9 else {return}
        DRFBService.share.facebook(comment: postData.id)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return data.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return (section == 0 || !data[section].expend) ? 0 : (data[section].reply?.count ?? 0)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            guard indexPath.section != 0 else {
                return FacebookDetailHeaderNode(title: self.postData.title)
            }
            let sectionNode = FacebookDetailSectionNode(data: self.data[indexPath.section])
            sectionNode.delegates = self
            return sectionNode
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            guard let data = self.reply(data: indexPath) else {return ASCellNode()}
            return FacebookDetailRowNode(data: data)
        }
    }
    
    /**
     해당 indexPath에 부합하는 reply data를 반환한다.
     - parameter indexPath: 찾고자 하는 indexPath.
     */
    private func reply(data indexPath: IndexPath) -> DRFBReply? {
        guard indexPath.section < data.count else {return nil}
        guard let data = data[indexPath.section].reply else {return nil}
        guard indexPath.row < data.count else {return nil}
        return data[indexPath.row]
    }
    
}

class FacebookDetailHeaderNode: ASCellNode {
    
    fileprivate let titleNode = ASTextNode()
    
    init(title: String) {
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.isLayerBacked = true
        let font = UIFont.systemFont(ofSize: 23.fit, weight: .bold)
        titleNode.attributedText = NSAttributedString(string: title, attributes: [.font : font])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets(t: 24.fit, l: 40.fit, b: 24.fit, r: 40.fit), child: titleNode)
    }
    
}

protocol FBDetailSectionDelegates: NSObjectProtocol {
    func expand(indexPath: IndexPath)
}

class FacebookDetailSectionNode: ASCellNode {
    
    weak var delegates: FBDetailSectionDelegates!
    
    fileprivate let backgroundNode = ASDisplayNode()
    fileprivate let portraitNode = ASImageNode()
    fileprivate let nameNode = ASTextNode()
    fileprivate let contentNode = ASTextNode()
    fileprivate let arrowNode = ASImageNode()
    fileprivate let replyNode = ASButtonNode()
    fileprivate let dateNode = ASTextNode()
    
    fileprivate var data: DRFBComment
    
    init(data: DRFBComment) {
        self.data = data
        super.init()
        automaticallyManagesSubnodes = true
        
        backgroundNode.backgroundColor = .white
        backgroundNode.isLayerBacked = true
        backgroundNode.cornerRadius = 13
        backgroundNode.shadowColor = UIColor(hex8: "56565626").cgColor
        backgroundNode.shadowOffset = CGSize(width: 0, height: 1)
        backgroundNode.shadowRadius = 2.5
        backgroundNode.shadowOpacity = 1
        
        portraitNode.contentMode = .scaleAspectFit
        portraitNode.image = #imageLiteral(resourceName: "info")
        
        nameNode.isLayerBacked = true
        nameNode.maximumNumberOfLines = 1
        let nameFont = UIFont.systemFont(ofSize: 13.fit, weight: .bold)
        let nameColor = UIColor(hex6: "365899")
        nameNode.attributedText = NSAttributedString(string: "작성자", attributes: [.font : nameFont, .foregroundColor : nameColor])
        
        contentNode.isLayerBacked = true
        let contentFont = UIFont.systemFont(ofSize: 15.fit)
        contentNode.attributedText = NSAttributedString(string: data.msg, attributes: [.font : contentFont])
        
        arrowNode.contentMode = .scaleAspectFit
        arrowNode.image = #imageLiteral(resourceName: "reply")
        
        replyNode.addTarget(self, action: #selector(action(button:)), forControlEvents: .touchUpInside)
        
        dateNode.isLayerBacked = true
        dateNode.maximumNumberOfLines = 1
        let dateFont = UIFont.systemFont(ofSize: 12.fit)
        let dateColor = UIColor.black.withAlphaComponent(0.8)
        dateNode.attributedText = NSAttributedString(string: data.create.timeFormat, attributes: [.font : dateFont, .foregroundColor : dateColor])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        portraitNode.style.preferredSize = CGSize(width: 25.5.fit, height: 25.5.fit)
        let portraitInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 6.fit, l: 11.5.fit), child: portraitNode)
        let nameInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 11.fit, l: 10.5.fit, r: 10.5.fit), child: nameNode)
        let h1Stack = ASStackLayoutSpec.horizontal()
        h1Stack.children = [portraitInset, nameInset]
        
        let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 7.5.fit, l: 15.fit, b: 15.fit, r: 15.fit), child: contentNode)
        
        let v1Stack = ASStackLayoutSpec.vertical()
        v1Stack.children = [h1Stack, contentInset]
        
        let backSpec = ASBackgroundLayoutSpec(child: v1Stack, background: backgroundNode)
        let backInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 8.fit, r: 8.fit), child: backSpec)
        
        arrowNode.style.preferredSize = CGSize(width: 13.fit, height: 13.fit)
        let arrowInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 27.5.fit, r: 8.fit), child: arrowNode)
        let replyInset = ASInsetLayoutSpec(insets: UIEdgeInsets(r: 8.fit), child: replyNode)
        let dateInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 9.5.fit), child: dateNode)
        
        let h2Stack = ASStackLayoutSpec.horizontal()
        h2Stack.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width), height: ASDimension(unit: .points, value: 34.fit))
        h2Stack.children = [arrowInset, replyInset, dateInset]
        
        let v2Stack = ASStackLayoutSpec.vertical()
        v2Stack.children = [backInset, h2Stack]
        return v2Stack
    }
    
    override func layout() {
        super.layout()
        initReplyNode()
    }
    
    private func initReplyNode() {
        var replyText = "facebookNoReply".locale
        if data.count > 0 {replyText = String(format: "facebookReply".locale, data.count)}
        let replyFont = UIFont.systemFont(ofSize: 12.fit, weight: .semibold)
        replyNode.isEnabled = (!data.expend && data.count > 0)
        let replyColor = replyNode.isEnabled ? UIColor(hex6: "007aff") : .black
        replyNode.setAttributedTitle(NSAttributedString(string: replyText, attributes: [.font : replyFont, .foregroundColor : replyColor]), for: .normal)
    }
    
    @objc private func action(button: ASButtonNode) {
        guard let indexPath = indexPath else {return}
        delegates.expand(indexPath: indexPath)
    }
    
}

class FacebookDetailRowNode: ASCellNode {
    
    fileprivate let backgroundNode = ASDisplayNode()
    fileprivate let portraitNode = ASImageNode()
    fileprivate let nameNode = ASTextNode()
    fileprivate let contentNode = ASTextNode()
    fileprivate let dateNode = ASTextNode()
    
    init(data: DRFBReply) {
        super.init()
        automaticallyManagesSubnodes = true
        
        backgroundNode.backgroundColor = .white
        backgroundNode.isLayerBacked = true
        backgroundNode.cornerRadius = 13
        backgroundNode.shadowColor = UIColor(hex8: "56565626").cgColor
        backgroundNode.shadowOffset = CGSize(width: 0, height: 1)
        backgroundNode.shadowRadius = 2.5
        backgroundNode.shadowOpacity = 1
        
        portraitNode.contentMode = .scaleAspectFit
        portraitNode.image = #imageLiteral(resourceName: "info")
        
        nameNode.isLayerBacked = true
        nameNode.backgroundColor = .white
        let nameFont = UIFont.systemFont(ofSize: 13.fit, weight: .bold)
        let nameColor = UIColor(hex6: "365899")
        nameNode.attributedText = NSAttributedString(string: " 작성자 ", attributes: [.font : nameFont, .foregroundColor : nameColor])
        
        contentNode.isLayerBacked = true
        let contentFont = UIFont.systemFont(ofSize: 15.fit)
        contentNode.attributedText = NSAttributedString(string: "작성자" + data.msg, attributes: [.font : contentFont])
        
        dateNode.isLayerBacked = true
        let dateFont = UIFont.systemFont(ofSize: 12.fit)
        let dateColor = UIColor.black.withAlphaComponent(0.8)
        dateNode.attributedText = NSAttributedString(string: data.create.timeFormat, attributes: [.font : dateFont, .foregroundColor : dateColor])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        contentNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width - 120.5.fit), height: ASDimensionAuto)
        let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 14.fit, l: 15.fit, b: 15.fit, r: 15.fit), child: contentNode)
        
        let nameInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 15.fit, l: 14.fit), child: nameNode)
        let absSpec = ASAbsoluteLayoutSpec(children: [contentInset, nameInset])
        let backSpec = ASBackgroundLayoutSpec(child: absSpec, background: backgroundNode)
        
        dateNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimension(unit: .points, value: 24.5.fit))
        let dateInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 9.5.fit, l: 19.5.fit), child: dateNode)
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.children = [backSpec, dateInset]
        
        portraitNode.style.preferredSize = CGSize(width: 25.5.fit, height: 25.5.fit)
        let portraitInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 6.fit, l: 53.fit, r: 6.fit), child: portraitNode)
        
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width), height: ASDimensionAuto)
        hStack.alignItems = .start
        hStack.children = [portraitInset, vStack]
        return hStack
    }
    
}

