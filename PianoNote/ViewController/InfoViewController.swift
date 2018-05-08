//
//  InfoViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit

typealias InfoData = (section: String, row: [String]?)

enum InfoPlace {
    case top, halfTop, middle, bottom, single
}

class InfoViewController: DRViewController {
    
    private let nodeCtrl = InfoNodeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubnode(nodeCtrl)
        initData()
    }
    
    private func initData() {
        nodeCtrl.data.append(InfoData(section: "Info", row: nil))
        nodeCtrl.data.append(InfoData(section: "회사", row: ["팀원", "목표", "문의하기"]))
        nodeCtrl.data.append(InfoData(section: "앱", row: ["버전정보", "라이센스"]))
        nodeCtrl.data.append(InfoData(section: "야호", row: ["뚜루룻"]))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nodeCtrl.frame = view.frame
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.nodeCtrl.listNode.contentInset.bottom = self.toolHeight
        })
    }
    
}

class InfoNodeController: ASDisplayNode {
    
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var data = [InfoData]()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 0
        listNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        listNode.contentInset.bottom = toolHeight
        listNode.view.alwaysBounceVertical = true
        listNode.backgroundColor = .clear
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
        guard let indexPath = listNode.indexPathForItem(at: point) else {return}
        print(indexPath)
    }
    
}

extension InfoNodeController: ASCollectionViewLayoutInspecting {
    
    func scrollableDirections() -> ASScrollDirection {
        return .down
    }
    
    func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
        return (kind == UICollectionElementKindSectionHeader) ? 1 : 0
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 55.fit))
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 45.fit))
    }
    
}

extension InfoNodeController: ASCollectionDelegate, ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return data.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return data[section].row?.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            let title = self.data[indexPath.section].section
            return InfoSectionNode(title: title, isHeader: indexPath.section == 0)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            guard let data = self.data[indexPath.section].row else {return ASCellNode()}
            let rowNode = InfoRowNode(title: data[indexPath.row])
            rowNode.place = self.node(place: indexPath)
            return rowNode
        }
    }
    
    /**
     해당 indexPath의 node가 section내 어디에 위치하는지를 판별한다.
     - parameter indexPath: Node의 indexPath값.
     */
    private func node(place indexPath: IndexPath) -> InfoPlace {
        let numberOfItems = listNode.numberOfItems(inSection: indexPath.section)
        if numberOfItems == 1 {
            return .single
        } else if numberOfItems == 2 {
            return (indexPath.row == 0) ? .halfTop : .bottom
        } else {
            if indexPath.row == 0 {
                return .top
            } else if indexPath.row == (numberOfItems - 1) {
                return .bottom
            } else {
                return .middle
            }
        }
    }
    
}

class InfoSectionNode: ASCellNode {
    
    fileprivate let titleNode = ASTextNode()
    
    init(title: String, isHeader: Bool) {
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.isLayerBacked = true
        let titleFont = UIFont.systemFont(ofSize: isHeader ? 34.fit : 14.fit,
                                          weight: isHeader ? .semibold : .regular)
        let titleColor = isHeader ? .black : UIColor(hex8: "0a0a0acc")
        titleNode.attributedText = NSAttributedString(string: title, attributes: [.font : titleFont, .foregroundColor : titleColor])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: constrainedSize.max.width),height: ASDimension(unit: .points, value: constrainedSize.max.height))
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: (indexPath?.section == 0) ? 20.fit : 30.fit,
                                                                l: (indexPath?.section == 0) ? 23.fit : 14.fit), child: titleNode)
        return titleInset
    }
    
}

class InfoRowNode: ASCellNode {
    
    fileprivate let topLineNode = ASImageNode()
    fileprivate let imageNode = ASImageNode()
    fileprivate let titleNode = ASTextNode()
    fileprivate let bottomLineNode = ASImageNode()
    
    fileprivate var place = InfoPlace.single
    
    init(title: String) {
        super.init()
        automaticallyManagesSubnodes = true
        topLineNode.isLayerBacked = true
        topLineNode.backgroundColor = UIColor(hex6: "c9c8cc")
        
        imageNode.contentMode = .scaleAspectFit
        imageNode.image = #imageLiteral(resourceName: "info")
        
        titleNode.isLayerBacked = true
        let titleFont = UIFont.systemFont(ofSize: 16.fit)
        titleNode.attributedText = NSAttributedString(string: title, attributes: [.font : titleFont])
        
        bottomLineNode.isLayerBacked = true
        bottomLineNode.backgroundColor = UIColor(hex6: "c9c8cc")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        topLineNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 0.5)
        let topLineInset = ASInsetLayoutSpec(insets: UIEdgeInsets(), child: topLineNode)
        
        imageNode.style.preferredSize = CGSize(width: 29.fit, height: 29.fit)
        let imageCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: imageNode)
        let imageInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 7.fit, l: 14.fit, b: 7.fit), child: imageCenter)
        
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 14.fit), child: titleCenter)
        
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.children = [imageInset, titleInset]
        
        bottomLineNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 0.5)
        let bottomLineInset = ASInsetLayoutSpec(insets: UIEdgeInsets(), child: bottomLineNode)
        
        if place == .top  {
            bottomLineNode.isHidden = true
        } else if place == .halfTop {
            bottomLineInset.insets.left = 54.fit
        } else if place == .middle {
            topLineInset.insets.left = 54.fit
            bottomLineInset.insets.left = 54.fit
        } else if place == .bottom {
            topLineNode.isHidden = true
        }
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.children = [topLineInset, hStack, bottomLineInset]
        return vStack
    }
    
}

