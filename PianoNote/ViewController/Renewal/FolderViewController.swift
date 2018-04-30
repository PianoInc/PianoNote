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

class FolderViewController: DRViewController {
    
    private let nodeCtrl = FolderNodeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubnode(nodeCtrl)
        initData()
        initNavi()
    }
    
    private func initData() {
        var data = [FolderData]()
        data.append(FolderData(section: "폴더", row: ["모든 메모", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]))
        data.append(FolderData(section: "삭제된 메모", row: nil))
        data.append(FolderData(section: "커뮤니티", row: nil))
        data.append(FolderData(section: "Info", row: nil))
        nodeCtrl.data = data
    }
    
    private func initNavi() {
        navi { (navi, item) in
            item.title = "folder".locale
            item.rightBarButtonItem?.title = "edit".locale
            navi.toolbarItems = toolbarItems
            navi.toolbarItems![1].title = String(format: "selectFolderCount".locale, 0)
        }
        nodeCtrl.countBinder.subscribe { [weak self] in
            self?.navigationController?.toolbarItems![1].title = String(format: "selectFolderCount".locale, $0)
        }
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
        nodeCtrl.removeCandidate.removeAll()
        nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 0...(nodeCtrl.data.count - 1)))
    }
    
    @IBAction private func tool(delete button: UIBarButtonItem) {
        nodeCtrl.data[0].row = nodeCtrl.data[0].row!.filter({
            let index = nodeCtrl.data[0].row!.index(of: $0)
            return !nodeCtrl.removeCandidate.contains(IndexPath(row: index!, section: 0))
        })
        nodeCtrl.removeCandidate.removeAll()
        if nodeCtrl.data[0].row!.count > 1 {
            nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 0...(nodeCtrl.data.count - 1)))
        } else {
            navi(edit: button)
        }
    }
    
}

class FolderNodeController: ASDisplayNode {
    
    fileprivate let newFolderButton = ASButtonNode()
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var data = [FolderData]()
    fileprivate var isEdit = false
    fileprivate var removeCandidate = [IndexPath]()
    fileprivate let countBinder = DRBinder(0)
    
    typealias MoveItemSpec = (origin: IndexPath, dest: IndexPath, item: UIView)
    fileprivate var moveItem = MoveItemSpec(origin: IndexPath(), dest: IndexPath(), item: UIView())
    
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
        newFolderButton.addTarget(self, action: #selector(action(newFolder:)), forControlEvents: .touchUpInside)
        newFolderButton.setAttributedTitle(NSAttributedString(string: "newFolder".locale,
                                                              attributes: [.font : UIFont.systemFont(ofSize: 17, weight: .regular),
                                                                           .foregroundColor : UIColor(hex6: "007aff")]), for: .normal)
        
        initViewGesture()
    }
    
    private func initViewGesture() {
        ASMainSerialQueue().performBlock {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.action(tap:)))
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.action(longPress:)))
            self.listNode.view.addGestureRecognizer(tap)
            self.listNode.view.addGestureRecognizer(longPress)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let listInset = ASInsetLayoutSpec(insets: safeArea(from: constrainedSize.max.width), child: listNode)
        
        newFolderButton.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: 118.auto), height: ASDimension(unit: .points, value: 44.5.auto))
        let buttonRelative = ASRelativeLayoutSpec(horizontalPosition: .end, verticalPosition: .end, sizingOption: .minimumSize, child: newFolderButton)
        let buttonInset = ASInsetLayoutSpec(insets: safeArea(from: constrainedSize.max.width), child: buttonRelative)
        
        return ASOverlayLayoutSpec(child: listInset, overlay: buttonInset)
    }
    
    private func safeArea(from width: CGFloat) -> UIEdgeInsets {
        var viewInset = safeInset
        viewInset.top += naviHeight
        let limitInset = (width - limitWidth) / 2
        if limitInset > 0 {
            viewInset.left += limitInset
            viewInset.right += limitInset
        }
        return viewInset
    }
    
    @objc private func action(newFolder: ASButtonNode) {
        let alert = UIAlertController(title: "newFolder".locale, message: "newFolderSubText".locale, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".locale, style: .cancel))
        alert.addAction(UIAlertAction(title: "create".locale, style: .default) { _ in
            self.data[0].row!.append(alert.textFields![0].text!)
            self.listNode.insertItems(at: [IndexPath(row: self.data[0].row!.count - 1, section: 0)])
        })
        alert.addTextField {
            $0.placeholder = "name".locale
            _ = $0.rx.text.orEmpty.subscribe {
                alert.actions[1].isEnabled = !$0.element!.isEmpty
            }
        }
        if let topViewController = UIWindow.topVC {
            topViewController.present(alert, animated: true)
        }
    }
    
    @objc private func action(tap: UITapGestureRecognizer) {
        guard isEdit else {return}
        let point = tap.location(in: listNode.view)
        guard let indexPath = listNode.indexPathForItem(at: point), indexPath.row != 0 else {return}
        if removeCandidate.contains(indexPath) {
            removeCandidate.remove(at: removeCandidate.index(where: {$0 == indexPath})!)
        } else {
            removeCandidate.append(indexPath)
        }
        listNode.reloadItems(at: [indexPath])
        countBinder.value = removeCandidate.count
    }
    
    @objc private func action(longPress: UILongPressGestureRecognizer) {
        guard isEdit else {return}
        let point = longPress.location(in: listNode.view)
        switch longPress.state {
        case .began:
            guard let indexPath = listNode.indexPathForItem(at: point), indexPath.row != 0 else {return}
            guard let item = listNode.nodeForItem(at: indexPath) as? FolderRowNode else {return}
            moveItem.origin = indexPath
            moveItem.dest = indexPath
            moveItem.item = item.view.snapshotView(afterScreenUpdates: true)!
            moveItem.item.center.y = point.y
            listNode.view.addSubview(moveItem.item)
        case .changed:
            guard let indexPath = listNode.indexPathForItem(at: point), indexPath.row != 0 else {return}
            guard let item = listNode.nodeForItem(at: indexPath) as? FolderRowNode else {return}
            moveItem.item.center.y = point.y
            if moveItem.dest != indexPath {
                data[0].row?.swapAt(moveItem.dest.row, indexPath.row)
                listNode.moveItem(at: moveItem.dest, to: indexPath)
                let origin = removeCandidate.index(where: {$0 == moveItem.dest})
                let dest = removeCandidate.index(where: {$0 == indexPath})
                if origin != nil && dest == nil {
                    removeCandidate.remove(at: origin!)
                    removeCandidate.append(indexPath)
                } else if origin == nil && dest != nil {
                    removeCandidate.remove(at: dest!)
                    removeCandidate.append(moveItem.dest)
                }
                moveItem.dest = indexPath
            } else {
                item.isHidden = true
            }
        default:
            listNode.reloadSections(IndexSet(integer: moveItem.origin.section))
            moveItem.item.removeFromSuperview()
        }
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
            rowNode.isSelect = self.removeCandidate.contains(indexPath)
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
        backgroundColor = .white
        
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
    let checkNode = ASImageNode()
    let titleNode = ASTextNode()
    let countNode = ASTextNode()
    let moveNode = ASImageNode()
    var isSelect = false
    var isEdit = false
    
    init(data: (title: String, count: String)) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        lineNode.backgroundColor = UIColor(hex6: "c8c7cc")
        lineNode.isLayerBacked = true
        
        checkNode.isLayerBacked = true
        
        titleNode.isLayerBacked = true
        titleNode.attributedText = NSAttributedString(string: data.title,
                                                      attributes: [.font : UIFont.systemFont(ofSize: 17, weight: .regular)])
        
        countNode.isLayerBacked = true
        countNode.attributedText = NSAttributedString(string: data.count,
                                                      attributes: [.font : UIFont.systemFont(ofSize: 13, weight: .regular),
                                                                   .foregroundColor : UIColor(hex6: "8a8a8f")])
        
        moveNode.isLayerBacked = true
        moveNode.image = #imageLiteral(resourceName: "listMoveIcon")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        lineNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimension(unit: .points, value: 0.5))
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
        checkNode.image = isSelect ? #imageLiteral(resourceName: "checkSelect") : #imageLiteral(resourceName: "checkEmpty")
    }
    
}

