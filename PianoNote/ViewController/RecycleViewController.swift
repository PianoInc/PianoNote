//
//  RecycleViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 1..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RealmSwift
import AsyncDisplayKit

class RecycleViewController: DRViewController {
    
    private let nodeCtrl = RecycleNodeController()
    private var results: Results<RealmNoteModel>?
    private var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nodeCtrl.viewCtrl = self
        view.addSubnode(nodeCtrl)
        initNavi()
        registerToken()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func registerToken() {
        guard let realm = try? Realm() else {return}
        
        //tagname is navTitle
        
        let sortDescriptors = [SortDescriptor(keyPath: "isPinned", ascending: false),
                               SortDescriptor(keyPath: "isModified", ascending: false)]
        
        let tag = RealmTagsModel.tagSeparator + "AllMemo".locale + RealmTagsModel.tagSeparator
        
        results = realm.objects(RealmNoteModel.self)
            .filter("isInTrash = true", tag)
            .sorted(by: sortDescriptors)
        
        //set results
        
        var data = [NoteData]()
        guard let results = results else {return}
        for model in results {
            let rowData = ["id" : model.id, "tag" : folder(with: model.tags), "con" : model.content]
            if data.contains(where: {$0.section == model.isModified.timeFormat}) {
                let index = data.index(where: {$0.section == model.isModified.timeFormat})!
                data[index].row?.append(rowData)
            } else {
                data.append(NoteData(section: model.isModified.timeFormat, row: [rowData]))
            }
        }
        nodeCtrl.data = data
    }
    
    private func folder(with data: String) -> String {
        var folder = ""
        let tags = data.components(separatedBy: RealmTagsModel.tagSeparator)
        for (idx, tag) in tags.enumerated() {
            guard idx != 0 && idx != (tags.count - 1) else {continue}
            if !tag.isEmpty {
                folder.append(tag)
            } else {
                folder.append(", ")
            }
        }
        return folder
    }
    
    private func initNavi() {
        navi { (navi, item) in
            item.title = "deleteMemo".locale
            item.rightBarButtonItem?.title = "edit".locale
            navi.isToolbarHidden = true
            navi.toolbarItems = toolbarItems
            navi.toolbarItems?[0].title = "restore".locale
            navi.toolbarItems?[2].title = String(format: "selectFolderCount".locale, 0)
        }
        nodeCtrl.countBinder.subscribe { [weak self] in
            self?.navigationController?.toolbarItems?[2].title = String(format: "selectFolderCount".locale, $0)
        }
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
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        navigationController?.isToolbarHidden = true
    }
    
    @objc private func navi(selectAll button: UIBarButtonItem) {
        let indexPath = nodeCtrl.data.enumerated().compactMap({ (section, data) in
            data.row?.enumerated().map({ (row, data) in
                IndexPath(row: row, section: section)
            })
        }).flatMap({$0})
        if nodeCtrl.candidate.count != indexPath.count {
            nodeCtrl.candidate = indexPath
        } else {
            nodeCtrl.candidate.removeAll()
        }
        guard !nodeCtrl.data.isEmpty else {return}
        nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 1...(nodeCtrl.data.count - 1)))
    }
    
    @IBAction private func navi(edit button: UIBarButtonItem) {
        nodeCtrl.isEditMode = !nodeCtrl.isEditMode
        navigationController?.isToolbarHidden = !nodeCtrl.isEditMode
        navigationItem.rightBarButtonItem?.title = nodeCtrl.isEditMode ? "cancel".locale : "edit".locale
        navigationItem.leftBarButtonItem = nil
        if nodeCtrl.isEditMode {
            let barButton = UIBarButtonItem(title: "selectAll".locale, style: .plain,
                                            target: self, action: #selector(navi(selectAll:)))
            navigationItem.leftBarButtonItem = barButton
        }
    }
    
    @IBAction private func tool(restore button: UIBarButtonItem) {
        nodeCtrl.candidate.removeAll()
        //nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 1...(nodeCtrl.data.count - 1)))
    }
    
    @IBAction private func tool(remove button: UIBarButtonItem) {
        nodeCtrl.candidate.removeAll()
        //nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 1...(nodeCtrl.data.count - 1)))
    }
    
}

typealias NoteData = (section: String, row: [[String : String]]?)

enum NodePlace {
    case top, middle, bottom, single
}

class RecycleNodeController: ASDisplayNode {
    
    fileprivate weak var viewCtrl: UIViewController?
    
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var data = [NoteData]()
    fileprivate var candidate = [IndexPath]() {
        didSet {countBinder.value = candidate.count}
    }
    fileprivate let countBinder = DRBinder(0)
    
    fileprivate var isEditMode = false
    
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
        if isEditMode {
            let point = tap.location(in: listNode.view)
            guard let indexPath = listNode.indexPathForItem(at: point) else {return}
            guard listNode.nodeForItem(at: indexPath) is RecycleRowNode else {return}
            if candidate.contains(indexPath) {
                candidate.remove(at: candidate.index(where: {$0 == indexPath})!)
            } else {
                candidate.append(indexPath)
            }
            listNode.reloadItems(at: [indexPath])
        } else {
            let point = tap.location(in: listNode.view)
            guard let indexPath = listNode.indexPathForItem(at: point) else {return}
            guard let noteViewCtrl = UIStoryboard(name: "Main1", bundle: nil)
                .instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController else {return}
            noteViewCtrl.noteID = data[indexPath.section].row![indexPath.row]["id"]
            viewCtrl?.present(view: noteViewCtrl)
        }
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
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 60.fit))
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 150.fit))
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
            let title = self.data[indexPath.section].section
            let recycleSectionNode = RecycleSectionNode(title: title)
            return recycleSectionNode
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { () -> ASCellNode in
            guard let data = self.data[indexPath.section].row?[indexPath.row] else {return ASCellNode()}
            let recycleRowNode = RecycleRowNode(folder: data["tag"]!)
            recycleRowNode.place = self.node(place: indexPath)
            recycleRowNode.isSelect = self.candidate.contains(indexPath)
            recycleRowNode.content = data["con"]
            return recycleRowNode
        }
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

class RecycleSectionNode: ASCellNode {
    
    fileprivate let titleNode = ASTextNode()
    
    init(title: String) {
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.isLayerBacked = true
        let titleFont = UIFont.systemFont(ofSize: 23.fit, weight: .bold)
        titleNode.attributedText = NSAttributedString(string: title, attributes: [.font : titleFont])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: titleNode)
        titleCenter.style.preferredSize = constrainedSize.max
        return ASInsetLayoutSpec(insets: UIEdgeInsets(l: indexPath?.section == 0 ? 24.fit: 31.fit), child: titleCenter)
    }
    
}

class RecycleRowNode: ASCellNode {
    
    fileprivate let backgroundNode = ASDisplayNode()
    fileprivate let foregroundNode = ASDisplayNode()
    fileprivate let folderNode = ASTextNode()
    fileprivate let titleNode = ASTextNode()
    fileprivate let contentNode = ASTextNode()
    
    fileprivate var place = NodePlace.single
    fileprivate var isSelect = false
    fileprivate var content: String?
    
    init(folder: String) {
        super.init()
        automaticallyManagesSubnodes = true
        
        backgroundNode.backgroundColor = UIColor(hex6: "eaebed")
        backgroundNode.isLayerBacked = true
        backgroundNode.cornerRadius = 14
        
        foregroundNode.backgroundColor = .white
        foregroundNode.isLayerBacked = true
        foregroundNode.cornerRadius = 10
        
        folderNode.maximumNumberOfLines = 1
        folderNode.isLayerBacked = true
        let folderFont = UIFont.systemFont(ofSize: 13.5.fit)
        folderNode.attributedText = NSAttributedString(string: folder, attributes: [.font : folderFont])
        
        titleNode.maximumNumberOfLines = 1
        titleNode.isLayerBacked = true
        
        contentNode.maximumNumberOfLines = 2
        contentNode.isLayerBacked = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let folderInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 14.fit, l: 15.5.fit, r: 15.5.fit), child: folderNode)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(t: 8.fit, l: 15.5.fit, b: 8.fit, r: 15.5.fit), child: titleNode)
        let contentInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 15.5.fit, b: 14.fit, r: 15.5.fit), child: contentNode)
        
        let vStack = ASStackLayoutSpec.vertical()
        vStack.children = [folderInset, titleInset, contentInset]
        
        let foreOver = ASOverlayLayoutSpec(child: foregroundNode, overlay: vStack)
        let foreInset = ASInsetLayoutSpec(insets: shapeInset().fore, child: foreOver)
        
        let backOver = ASOverlayLayoutSpec(child: backgroundNode, overlay: foreInset)
        return ASInsetLayoutSpec(insets: shapeInset().back, child: backOver)
    }
    
    private func shapeInset() -> (fore: UIEdgeInsets, back: UIEdgeInsets) {
        var fore = UIEdgeInsets(t: 6.fit, l: 6.fit, b: 6.fit, r: 6.fit)
        var back = UIEdgeInsets(l: 12.5.fit, r: 12.5.fit)
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
        selectionBorder()
    }
    
    private func continuousText() {
        guard let content = content else {return}
        let titleFont = UIFont.systemFont(ofSize: 29.2.fit, weight: .bold)
        let titleAttStr = NSAttributedString(string: content, attributes: [.font : titleFont])
        let trimTitle = titleAttStr.firstLine(width: titleNode.frame.width).string.trimmingCharacters(in: .whitespacesAndNewlines)
        titleNode.attributedText = NSAttributedString(string: trimTitle, attributes: [.font : titleFont])
        
        let contentText = titleAttStr.string.sub(titleNode.attributedText!.length...)
        let trimContent = contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        let contentFont = UIFont.systemFont(ofSize: 16.8.fit)
        contentNode.attributedText = NSAttributedString(string: trimContent, attributes: [.font : contentFont])
    }
    
    private func selectionBorder() {
        foregroundNode.borderColor = UIColor(hex6: isSelect ? "1784ff" : "b5b5b5").cgColor
        foregroundNode.borderWidth = isSelect ? 2 : 0.5
    }
    
}

