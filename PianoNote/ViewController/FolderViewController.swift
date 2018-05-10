//
//  FolderViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RealmSwift

fileprivate let allFolderName = "allMemo".locale

class FolderViewController: DRViewController {
    
    @IBOutlet private var newFolderButton: UIButton!
    
    private let nodeCtrl = FolderNodeController()
//    private let newFolderButton = UIButton(type: .system)
    fileprivate var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nodeCtrl.isHidden = true
        nodeCtrl.viewController = self
        view.addSubnode(nodeCtrl)
        newFolderButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.fit, weight: .regular)
        newFolderButton.setTitle("newFolder".locale, for: .normal)
        view.bringSubview(toFront: newFolderButton)
        initConst()
        initData()
        initNavi()
        setNotificationToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nodeCtrl.listNode.reloadSections(IndexSet(integer: 0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fadePush()
    }
    
    private func fadePush() {
        guard nodeCtrl.isHidden else {return}
        UIView.transition(with: navigationController!.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            let noteListViewCtrl = UIStoryboard.view(type: NoteListViewController.self)
            noteListViewCtrl.navTitle = "allMemo".locale
            self.present(view: noteListViewCtrl, animated: false)
        }, completion: { _ in
            self.nodeCtrl.isHidden = false
            self.nodeCtrl.listNode.contentInset.bottom = self.toolHeight
            self.newFolderButton.isHidden = false
        })
    }
    
    private func setNotificationToken () {
        guard let realm = try? Realm(),
            let tagsModel = realm.objects(RealmTagsModel.self).first else { return }
        notificationToken = tagsModel.observe { [weak self] change in
            switch change {
            case .change(let changes):
                changes.forEach {
                    if $0.name == Schema.Tags.tags {
                        guard let newTags = $0.newValue as? String else {return}
                        var tags = newTags.components(separatedBy: RealmTagsModel.tagSeparator)
                        tags[0] = allFolderName
                        self?.tagsUpdated(newTags: tags)
                    }
                }
            default: break
            }
        }
    }
    
    private func tagsUpdated(newTags: [String]) {
        guard let oldTags = nodeCtrl.data[0].row else { return }

        var inserted: [IndexPath] = []
        var changed: [IndexPath] = []
        var deleted: [IndexPath] = []

        let minLength = min(oldTags.count, newTags.count)

        for i in 0..<minLength {
            if oldTags[i] != newTags[i] {
                changed.append(IndexPath(item: i, section: 0))
            }
        }

        if oldTags.count > newTags.count {
            deleted = (minLength..<oldTags.count).map { IndexPath(item: $0, section: 0)}
        } else {
            inserted = (minLength..<newTags.count).map { IndexPath(item: $0, section: 0)}
        }
        nodeCtrl.data[0].row = newTags

        nodeCtrl.listNode.reloadItems(at: changed)

        if !deleted.isEmpty {
            nodeCtrl.listNode.deleteItems(at: deleted)
        }

        if !inserted.isEmpty {
            nodeCtrl.listNode.insertItems(at: inserted)
        }
        
    }
    
    private func initConst() {
        makeConst(newFolderButton) {
            $0.bottom.equalTo(-(self.safeInset.bottom + 5.fit))
            $0.trailing.equalTo(-(self.safeInset.right + 15.fit))
        }
    }
    
    private func initData() {
        var data = [FolderData]()
        if let realm = try? Realm(),
            let tagsModel = realm.objects(RealmTagsModel.self).first {
            var tags = tagsModel.tags.components(separatedBy: RealmTagsModel.tagSeparator)
            tags[0] = allFolderName
            data.append(FolderData(section: "category".locale, row: tags))
        } else {
            ModelManager.saveNew(model: RealmTagsModel.getNewModel())
            data.append(FolderData(section: "category".locale, row: [allFolderName]))
        }
        
        data.append(FolderData(section: "deleteMemo".locale, row: nil))
        data.append(FolderData(section: "community".locale, row: nil))
        data.append(FolderData(section: "info".locale, row: nil))
        nodeCtrl.data = data
    }
    
    private func initNavi() {
        navi { (navi, item) in
            navi.navigationBar.alpha = 0
            item.title = "category".locale
            item.rightBarButtonItem?.title = "edit".locale
            navi.toolbarItems = toolbarItems
            navi.toolbarItems![1].title = String(format: "selectFolderCount".locale, 0)
        }
        nodeCtrl.countBinder.subscribe { [weak self] in
            self?.navigationController?.toolbarItems?[1].title = String(format: "selectFolderCount".locale, $0)
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
            self.initConst()
        })
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        navigationController?.isToolbarHidden = true
    }
    
    @IBAction private func navi(edit button: UIBarButtonItem) {
        nodeCtrl.isEdit = !nodeCtrl.isEdit
        device(orientationLock: nodeCtrl.isEdit)
        newFolderButton.isHidden = nodeCtrl.isEdit
        navi { (navi, item) in
            let toEditMode = (button.title == "edit".locale)
            item.rightBarButtonItem?.title = toEditMode ? "done".locale : "edit".locale
            navi.isToolbarHidden = !toEditMode
        }
        nodeCtrl.removeCandidate.removeAll()
        nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 0...(nodeCtrl.data.count - 1)))
    }
    
    @IBAction private func tool(delete button: UIBarButtonItem) {
        
        var datas = nodeCtrl.data[0].row!
        datas[0] = ""
        datas = datas.filter({
            return !nodeCtrl.removeCandidate.contains($0)
        })
        
        let tags = datas.joined(separator: RealmTagsModel.tagSeparator)
        nodeCtrl.removeCandidate.removeAll()
        
        guard let realm = try? Realm(),
            let tagsModel = realm.objects(RealmTagsModel.self).first else {return}
        ModelManager.update(id: tagsModel.id, type: RealmTagsModel.self, kv: [Schema.Tags.tags: tags])
//        if nodeCtrl.data[0].row!.count > 1 {
//            nodeCtrl.listNode.reloadSections(IndexSet(integersIn: 0...(nodeCtrl.data.count - 1)))
//        } else {
//            navi(edit: button)
//        }
    }
    
    @IBAction private func action(newFolder: ASButtonNode) {
        let alert = UIAlertController(title: "newFolder".locale, message: "newFolderSubText".locale, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".locale, style: .cancel))
        alert.addAction(UIAlertAction(title: "create".locale, style: .default) { _ in
            guard let realm = try? Realm(),
                let tagsModel = realm.objects(RealmTagsModel.self).first else { return }

            var tags = self.nodeCtrl.data[0].row!
            tags[0] = ""
            tags.append(alert.textFields![0].text!)

            ModelManager.update(id: tagsModel.id, type: RealmTagsModel.self,
                    kv: [Schema.Tags.tags: tags.joined(separator: RealmTagsModel.tagSeparator)])
        })
        alert.addTextField {
            $0.placeholder = "name".locale
            _ = $0.rx.text.orEmpty.subscribe {
                guard let text = $0.element else {return}
                alert.message = self.nodeCtrl.data[0].row!.contains(text) ? "newFolderExist".locale : "newFolderSubText".locale
                alert.actions[1].isEnabled = !(text.isEmpty || self.nodeCtrl.data[0].row!.contains(text))
            }
        }
        if let topViewController = UIWindow.topVC {
            topViewController.present(alert, animated: true)
        }
    }
    
}

typealias FolderData = (section: String, row: [String]?)

class FolderNodeController: ASDisplayNode {
    
    typealias MoveItemSpec = (origin: IndexPath, dest: IndexPath, item: UIView)
    fileprivate var moveItem = MoveItemSpec(origin: IndexPath(), dest: IndexPath(), item: UIView())
    
    fileprivate let listNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    
    fileprivate var data = [FolderData]()
    fileprivate var removeCandidate = [String]() {
        didSet {countBinder.value = removeCandidate.count}
    }
    
    fileprivate let countBinder = DRBinder(0)
    fileprivate var isEdit = false
    fileprivate weak var viewController: UIViewController?
    var realm: Realm?
    
    fileprivate let uDetectNode = ASDisplayNode()
    fileprivate let dDetectNode = ASDisplayNode()
    fileprivate var scroller: Timer!
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        uDetectNode.backgroundColor = .clear
        dDetectNode.backgroundColor = .clear
        
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (listNode.view.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = 0
        listNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        listNode.view.alwaysBounceVertical = true
        listNode.backgroundColor = .clear
        listNode.allowsSelection = false
        listNode.layoutInspector = self
        listNode.dataSource = self
        listNode.delegate = self
        initListGesture()
        realm = try? Realm()
    }
    
    private func initListGesture() {
        ASMainSerialQueue().performBlock {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.action(tap:)))
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.action(longPress:)))
            self.listNode.view.addGestureRecognizer(tap)
            self.listNode.view.addGestureRecognizer(longPress)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: safeArea(from: constrainedSize.max.width), child: listNode)
    }
    
    @objc private func action(tap: UITapGestureRecognizer) {
        if isEdit {
            let point = tap.location(in: listNode.view)
            guard let indexPath = listNode.indexPathForItem(at: point), indexPath.row != 0 else {return}
            guard let item = listNode.nodeForItem(at: indexPath) as? FolderRowNode else {return}
            guard let title = item.titleNode.attributedText?.string else {return}
            if removeCandidate.contains(title) {
                removeCandidate.remove(at: removeCandidate.index(where: {$0 == title})!)
            } else {
                removeCandidate.append(title)
            }
            listNode.reloadItems(at: [indexPath])
        } else {
            let point = tap.location(in: listNode.view)
            guard let indexPath = listNode.indexPathForItem(at: point) else {return}
            let noteListViewCtrl = UIStoryboard.view(type: NoteListViewController.self)
            noteListViewCtrl.navTitle = data[indexPath.section].row![indexPath.row]
            viewController?.present(view: noteListViewCtrl)
        }
    }
    
    @objc private func action(longPress: UILongPressGestureRecognizer) {
        guard isEdit else {return}
        let point = longPress.location(in: listNode.view)
        switch longPress.state {
        case .began:
            guard let indexPath = listNode.indexPathForItem(at: point), indexPath.row != 0 else {return}
            moveItem.origin = indexPath
            moveItem.dest = indexPath
            guard let item = listNode.nodeForItem(at: indexPath) as? FolderRowNode else {return}
            moveItem.item = item.view.snapshotView(afterScreenUpdates: true)!
            moveItem.item.shadow(color: UIColor.black.withAlphaComponent(0.5), offset: [0, 0], rad: 10)
            moveItem.item.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            moveItem.item.center.y = point.y
            listNode.view.addSubview(moveItem.item)
            item.isHidden = true
            autoScroll(prepare: true)
        case .changed:
            guard !moveItem.origin.isEmpty else {return}
            moveItem.item.center.y = point.y
            if !autoScroll(move: point) {
                guard let indexPath = listNode.indexPathForItem(at: point), indexPath.row != 0 else {return}
                if moveItem.dest != indexPath {
                    listNode.moveItem(at: moveItem.dest, to: indexPath)
                    moveItem.dest = indexPath
                }
                listNode.nodeForItem(at: indexPath)?.isHidden = true
                autoScroll(prepare: false)
            }
        default:
            guard !moveItem.origin.isEmpty else {return}
            if let delete = data[0].row?.remove(at: moveItem.origin.row) {
                data[0].row?.insert(delete, at: moveItem.dest.row)
                
                var tags = data[0].row!
                tags[0] = ""
                guard let realm = try? Realm(),
                    let tagsModel = realm.objects(RealmTagsModel.self).first else {return}
                
                ModelManager.update(id: tagsModel.id, type: RealmTagsModel.self,
                                    kv: [Schema.Tags.tags: tags.joined(separator: RealmTagsModel.tagSeparator)])
            }
            listNode.reloadSections(IndexSet(integer: moveItem.origin.section))
            moveItem.item.removeFromSuperview()
            moveItem = MoveItemSpec(origin: IndexPath(), dest: IndexPath(), item: UIView())
            autoScroll(prepare: false, with: true)
        }
    }
    
    private func autoScroll(prepare: Bool, with detector: Bool = false) {
        if prepare {
            uDetectNode.frame = CGRect(x: 0, y: listNode.contentOffset.y + naviHeight,
                                       width: listNode.bounds.width, height: 40.fit)
            listNode.addSubnode(uDetectNode)
            let offset = listNode.bounds.height - 40.fit - toolHeight
            dDetectNode.frame = CGRect(x: 0, y: listNode.contentOffset.y + offset,
                                       width: listNode.bounds.width, height: 40.fit)
            listNode.addSubnode(dDetectNode)
        } else {
            if detector {
                uDetectNode.removeFromSupernode()
                dDetectNode.removeFromSupernode()
            }
            guard scroller != nil else {return}
            scroller.invalidate()
            scroller = nil
        }
    }
    
    private func autoScroll(move point: CGPoint) -> Bool {
        if uDetectNode.frame.contains(point) {
            if scroller == nil {
                scroller = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    let offsetY = self.listNode.contentOffset.y - 40.fit
                    guard offsetY > -self.naviHeight else {
                        self.scroller.invalidate()
                        self.moveItem.item.center.y -= self.naviHeight + self.listNode.contentOffset.y
                        self.listNode.setContentOffset(CGPoint(x: 0, y: -self.naviHeight), animated: false)
                        return
                    }
                    self.moveItem.item.center.y -= 40.fit
                    self.listNode.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                }
            }
        } else if dDetectNode.frame.contains(point) {
            if scroller == nil {
                scroller = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    let offsetY = self.listNode.contentOffset.y + 40.fit
                    let max = self.listNode.view.contentSize.height - self.listNode.bounds.height + self.toolHeight * 2
                    guard offsetY < max else {
                        self.scroller.invalidate()
                        self.moveItem.item.center.y += max - self.listNode.contentOffset.y
                        self.listNode.setContentOffset(CGPoint(x: 0, y: max), animated: false)
                        return
                    }
                    self.moveItem.item.center.y += 40.fit
                    self.listNode.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                }
            }
        }
        return uDetectNode.frame.contains(point) || dDetectNode.frame.contains(point)
    }
    
}

extension FolderNodeController: ASCollectionViewLayoutInspecting {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        uDetectNode.frame.origin.y = naviHeight + scrollView.contentOffset.y
        let offset = listNode.bounds.height - 40.fit - toolHeight
        dDetectNode.frame.origin.y = offset + scrollView.contentOffset.y
    }
    
    func scrollableDirections() -> ASScrollDirection {
        return .down
    }
    
    func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
        return (kind == UICollectionElementKindSectionHeader) ? 1 : 0
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind kind: String, at indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: (indexPath.section == 0) ? 15.fit : 80.fit))
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRange(min: .zero, max: CGSize(width: collectionView.bounds.width, height: 40.fit))
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
            guard indexPath.section != 0 else {return ASCellNode()}
            let sectionNode = FolderSectionNode(title: data.section)
            sectionNode.isEdit = self.isEdit
            return sectionNode
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let data = self.data[indexPath.section].row!
        let tag = RealmTagsModel.tagSeparator + data[indexPath.row] + RealmTagsModel.tagSeparator
        var count: Int? = nil
        
        if data[indexPath.row] == allFolderName {
            if let results = realm?.objects(RealmNoteModel.self).filter("isInTrash = false") {
                count = results.count
            }
        } else {
            if let results = realm?.objects(RealmNoteModel.self)
                .filter("tags CONTAINS[cd] %@ AND isInTrash = false", tag) {
                count = results.count
            }
        }
        
        return { () -> ASCellNode in
            let rowNode = FolderRowNode(title: data[indexPath.row], count: String(count ?? 0))
            
            guard indexPath.row != 0 else {return rowNode}
            rowNode.isSelect = self.removeCandidate.contains(data[indexPath.row])
            rowNode.isEdit = self.isEdit
            return rowNode
        }
    }

}

class FolderSectionNode: ASCellNode {
    
    fileprivate let titleNode = ASTextNode()
    fileprivate let arrowNode = ASImageNode()
    
    fileprivate var isEdit = false
    
    init(title: String) {
        super.init()
        automaticallyManagesSubnodes = true
        
        titleNode.isLayerBacked = true
        let titleFont = UIFont.systemFont(ofSize:22.fit, weight: .bold)
        titleNode.attributedText = NSAttributedString(string: title, attributes: [.font : titleFont])
        
        arrowNode.image = #imageLiteral(resourceName: "nextArrow")
        
        ASMainSerialQueue().performBlock {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.action(select:)))
            self.view.addGestureRecognizer(tap)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: titleNode)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 16.5.fit), child: titleCenter)
        
        arrowNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: 8.fit), height: ASDimension(unit: .points, value: 13.fit))
        let arrowCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: arrowNode)
        let arrowInset = ASInsetLayoutSpec(insets: UIEdgeInsets(r: 16.fit), child: arrowCenter)
        
        let hStack = ASStackLayoutSpec.horizontal()
        hStack.style.preferredSize = constrainedSize.max
        hStack.style.preferredSize.height -= 20.fit
        hStack.justifyContent = .spaceBetween
        hStack.children = [titleInset, arrowInset]
        return hStack
    }
    
    override func layout() {
        super.layout()
        alpha = isEdit ? 0.2 : 1
    }

    @objc private func action(select: UITapGestureRecognizer) {
        guard let currentVC = UIWindow.topVC, let indexPath = indexPath else {return}
        if indexPath.section == 1 {
            currentVC.present(id: "RecycleViewController")
        } else if indexPath.section == 2 {
            currentVC.present(id: "FacebookViewController")
        } else if indexPath.section == 3 {
            currentVC.present(id: "InfoViewController")
        }
    }
    
}

class FolderRowNode: ASCellNode {
    
    fileprivate let lineNode = ASDisplayNode()
    fileprivate let checkNode = ASImageNode()
    fileprivate let titleNode = ASTextNode()
    fileprivate let countNode = ASTextNode()
    fileprivate let moveNode = ASImageNode()
    
    fileprivate var isSelect = false
    fileprivate var isEdit = false
    
    init(title: String, count: String) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = UIColor(hex6: "f9f9f9")
        
        lineNode.backgroundColor = UIColor(hex6: "c8c7cc")
        lineNode.isLayerBacked = true
        
        titleNode.isLayerBacked = true
        let titleFont = UIFont.systemFont(ofSize: 17.fit)
        titleNode.attributedText = NSAttributedString(string: title, attributes: [.font : titleFont])
        
        countNode.isLayerBacked = true
        let countFont = UIFont.systemFont(ofSize: 17.fit)
        countNode.attributedText = NSAttributedString(string: count, attributes: [.font : countFont, .foregroundColor : UIColor(hex6: "8a8a8f")])
        
        moveNode.image = #imageLiteral(resourceName: "listMoveIcon")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        lineNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimensionAuto, height: ASDimension(unit: .points, value: 0.5))
        let lineInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: 16.fit, r: 16.fit), child: lineNode)
        
        checkNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: 22.fit), height: ASDimension(unit: .points, value: 22.fit))
        let checkCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: checkNode)
        let checkInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: isEdit ? 14.fit: -36.fit), child: checkCenter)
        
        let titleCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: titleNode)
        let titleInset = ASInsetLayoutSpec(insets: UIEdgeInsets(l: isEdit ? 13.5.fit: 35.fit), child: titleCenter)
        
        let titleHStack = ASStackLayoutSpec.horizontal()
        titleHStack.children = [checkInset, titleInset]
        
        let countCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: countNode)
        let countInset = ASInsetLayoutSpec(insets: UIEdgeInsets(r: isEdit ? 16.fit: 22.fit), child: countCenter)
        
        moveNode.style.preferredLayoutSize = ASLayoutSize(width: ASDimension(unit: .points, value: 24.5.fit), height: ASDimension(unit: .points, value: 9.fit))
        let moveCenter = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: moveNode)
        let moveInset = ASInsetLayoutSpec(insets: UIEdgeInsets(r: isEdit ? 18.fit: -42.5.fit), child: moveCenter)
        
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

