//
//  FolderViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit

typealias FolderData = (section: String, row: [String]?)

class FolderViewController: UIViewController {
    
    private let nodeCtrl = FolderNodeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubnode(nodeCtrl)
        initData()
        navi { (navi, item) in
            item.title = "folder".locale
            item.rightBarButtonItem?.title = "edit".locale
            navi.toolbarItems = toolbarItems
            guard let newFolder = navi.toolbarItems?[3] else {return}
            newFolder.title = String(format: "selectFolderCount".locale, 0)
        }
    }
    
    private func initData() {
        var data = [FolderData]()
        data.append(FolderData(section: "폴더", row: ["모든 메모", "검은등할미새", "두루미", "개개비사촌", "검은등할미새", "두루미", "개개비사촌", "검은등할미새", "두루미", "개개비사촌"]))
        data.append(FolderData(section: "삭제된 메모", row: nil))
        data.append(FolderData(section: "커뮤니티", row: nil))
        data.append(FolderData(section: "Info", row: nil))
        nodeCtrl.data = data
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nodeCtrl.frame = view.frame
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        navigationController?.isToolbarHidden = true
    }
    
}

extension FolderViewController {
    
    @IBAction private func navi(edit button: UIBarButtonItem) {
        navi { (navi, item) in
            let toEditMode = (button.title == "edit".locale)
            item.rightBarButtonItem?.title = toEditMode ? "done".locale : "edit".locale
            navi.isToolbarHidden = !toEditMode
        }
        nodeCtrl.isEdit = !nodeCtrl.isEdit
        nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 0...(nodeCtrl.data.count - 1)))
    }
    
}

class FolderNodeController: ASDisplayNode {
    
    fileprivate let newFolderButton = ASButtonNode()
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var data = [FolderData]() {
        didSet {listNode.reloadData()}
    }
    fileprivate var isEdit = false
    
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
        
        newFolderButton.backgroundColor = .white
        newFolderButton.setAttributedTitle(NSAttributedString.init(string: "newMemoSubText".locale,
                                                                   attributes: [.font : UIFont.systemFont(ofSize: 17, weight: .regular),
                                                                                .foregroundColor : UIColor(hex6: "007aff")]), for: .normal)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var viewInset = safeInset
        viewInset.top += naviHeight
        let listInset = ASInsetLayoutSpec(insets: viewInset, child: listNode)
        
        newFolderButton.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: 118.auto), height: ASDimension(unit: .points, value: 44.5.auto))
        let buttonRelative = ASRelativeLayoutSpec(horizontalPosition: .end, verticalPosition: .end, sizingOption: .minimumSize, child: newFolderButton)
        let buttonInset = ASInsetLayoutSpec(insets: viewInset, child: buttonRelative)
        
        return ASOverlayLayoutSpec(child: listInset, overlay: buttonInset)
    }
    
}

extension FolderNodeController: ASCollectionViewLayoutInspecting {
    
    func scrollableDirections() -> ASScrollDirection {
        return .down
    }
    
    func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
        return (kind == UICollectionElementKindSectionHeader) ? 1 : 0
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 80.auto))
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 40.auto))
    }
    
}

extension FolderNodeController: ASCollectionDelegate, ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return data.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return data[section].row?.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        let data = self.data[indexPath.section]
        return { () -> ASCellNode in
            let sectionNode = FolderSectionNode(data: (title: data.section, isFolder: data.row != nil))
            guard indexPath.section != 0 else {return sectionNode}
            sectionNode.isEdit = self.isEdit
            return sectionNode
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let data = self.data[indexPath.section].row!
        return { () -> ASCellNode in
            let rowNode = FolderRowNode(data: (title: data[indexPath.row], count: String(data.count)))
            guard indexPath.row != 0 else {return rowNode}
            rowNode.isEdit = self.isEdit
            return rowNode
        }
    }
    
}

class FolderSectionNode: ASCellNode {
    
    let titleNode = ASTextNode()
    let arrowNode = ASImageNode()
    var isFolder = true
    var isEdit = false
    
    init(data: (title: String, isFolder: Bool)) {
        self.isFolder = data.isFolder
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.isLayerBacked = true
        titleNode.attributedText = NSAttributedString(string: data.title, attributes: [.font : UIFont.systemFont(ofSize: isFolder ? 34 : 22, weight: .bold)])
        
        arrowNode.isLayerBacked = true
        arrowNode.isHidden = isFolder
        arrowNode.image = #imageLiteral(resourceName: "nextArrow")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: titleNode)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: isFolder ? 24.5.auto : 16.5.auto), child: titleCenter)
        
        arrowNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .auto, value: 8.auto), height: ASDimension(unit: .points, value: 13.auto))
        let arrowCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: arrowNode)
        let arrowInset = ASInsetLayoutSpec(insets: UIEdgeInsets(r: 16.auto), child: arrowCenter)
        
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.style.preferredSize = constrainedSize.max
        if !isFolder {hStack.style.preferredSize.height -= 20.auto}
        hStack.justifyContent = .spaceBetween
        hStack.children = [titleInset, arrowInset]
        return hStack
    }
    
    override func layout() {
        super.layout()
        alpha = isEdit ? 0.2 : 1
    }
    
}

class FolderRowNode: ASCellNode {
    
    let lineNode = ASDisplayNode()
    let checkNode = ASDisplayNode()
    let titleNode = ASTextNode()
    let countNode = ASTextNode()
    let moveNode = ASDisplayNode()
    var isEdit = false
    
    init(data: (title: String, count: String)) {
        super.init()
        automaticallyManagesSubnodes = true
        
        lineNode.backgroundColor = UIColor(hex6: "c8c7cc")
        lineNode.isLayerBacked = true
        
        checkNode.isLayerBacked = true
        checkNode.borderWidth = 1
        checkNode.borderColor = UIColor.lightGray.cgColor
        
        titleNode.isLayerBacked = true
        titleNode.attributedText = NSAttributedString(string: data.title,
                                                      attributes: [.font : UIFont.systemFont(ofSize: 17, weight: .regular)])
        
        countNode.isLayerBacked = true
        countNode.attributedText = NSAttributedString(string: data.count,
                                                      attributes: [.font : UIFont.systemFont(ofSize: 13, weight: .regular),
                                                                   .foregroundColor : UIColor(hex6: "8a8a8f")])
        
        moveNode.isLayerBacked = true
        moveNode.backgroundColor = .lightGray
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        lineNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .auto, value: 0), height: ASDimension(unit: .points, value: 0.5))
        let lineInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 16.auto, r: 16.auto), child: lineNode)
        
        checkNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: 22.auto), height: ASDimension(unit: .points, value: 22.auto))
        let checkCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: checkNode)
        let checkInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: isEdit ? 14.auto : -36.auto), child: checkCenter)
        
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: titleNode)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: isEdit ? 13.5.auto : 35.auto), child: titleCenter)
        
        let titleHStack = ASStackLayoutSpec.horizontal()
        titleHStack.children = [checkInset, titleInset]
        
        let countCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: countNode)
        let countInset = ASInsetLayoutSpec(insets: UIEdgeInsets(r: isEdit ? 16.auto : 22.auto), child: countCenter)
        
        moveNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: 24.5.auto), height: ASDimension(unit: .points, value: 9.auto))
        let moveCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: moveNode)
        let moveInset = ASInsetLayoutSpec(insets: UIEdgeInsets(r: isEdit ? 18.auto : -42.5.auto), child: moveCenter)
        
        let countHStack = ASStackLayoutSpec.horizontal()
        countHStack.children = [countInset, moveInset]
        
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.style.preferredSize = constrainedSize.max
        hStack.justifyContent = .spaceBetween
        hStack.children = [titleHStack, countHStack]
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.children = [lineInset, hStack]
        return vStack
    }
    
    override func layout() {
        super.layout()
        checkNode.cornerRadius = checkNode.frame.width / 2
    }
    
}

