//
//  RecycleViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 1..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class RecycleViewController: DRViewController {
    
    private let nodeCtrl = RecycleNodeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubnode(nodeCtrl)
        initData()
        initNavi()
    }
    
    private func initData() {
        var data = [NoteData]()
        data.append(NoteData(section: "삭제된 메모", row: nil))
        data.append(NoteData(section: "오늘", row: ["연주하기", "소통공간"]))
        data.append(NoteData(section: "1월 18일", row: ["폴더명", "날짜"]))
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
            self?.navigationController?.toolbarItems?[1].title = String(format: "selectFolderCount".locale, $0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nodeCtrl.frame = view.frame
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.nodeCtrl.listNode.contentInset.bottom = self.inputHeight
        })
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        navigationController?.isToolbarHidden = true
    }
    
    @IBAction private func navi(selectAll button: UIBarButtonItem) {
        nodeCtrl.candidate = nodeCtrl.data.enumerated().compactMap({ (section, data) in
            data.row?.enumerated().map({ (row, data) in
                IndexPath(row: row, section: section)
            })
        }).flatMap({$0})
        nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 1...(nodeCtrl.data.count - 1)))
    }
    
    @IBAction private func tool(restore button: UIBarButtonItem) {
        nodeCtrl.candidate.removeAll()
        nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 1...(nodeCtrl.data.count - 1)))
    }
    
    @IBAction private func tool(remove button: UIBarButtonItem) {
        nodeCtrl.candidate.removeAll()
        nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 1...(nodeCtrl.data.count - 1)))
    }
    
}

typealias NoteData = (section: String, row: [String]?)

class RecycleNodeController: ASDisplayNode {
    
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var data = [NoteData]()
    fileprivate var candidate = [IndexPath]() {
        didSet {countBinder.value = candidate.count}
    }
    fileprivate let countBinder = DRBinder(0)
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 0
        listNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        listNode.contentInset.bottom = inputHeight
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
        guard let indexPath = listNode.indexPathForItem(at: point) else {return}
        guard listNode.nodeForItem(at: indexPath) is FolderRowNode else {return}
        if candidate.contains(indexPath) {
            candidate.remove(at: candidate.index(where: {$0 == indexPath})!)
        } else {
            candidate.append(indexPath)
        }
        listNode.reloadItems(at: [indexPath])
    }
    
}

extension RecycleNodeController: ASCollectionViewLayoutInspecting {
    
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
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 150.auto))
    }
    
}

extension RecycleNodeController: ASCollectionDelegate, ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return data.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return data[section].row?.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            return ASCellNode()
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            return ASCellNode()
        }
    }
    
}

class RecycleSectionNode: ASCellNode {

}

class RecycleRoWNode: ASCellNode {
    
}

