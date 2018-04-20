//
//  MainListViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

class MainListViewController: DRViewController {
    
    @IBOutlet private var listView: UICollectionView!
    @IBOutlet private var pageControl: DRPageControl!
    
    private var tags: RealmTagsModel?
    private var notificationToken: NotificationToken?
    private var destIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initConst()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
        initToolBar()
        validateToken()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    /// Constraints 설정
    private func initConst() {
        makeConst(listView) {
            $0.leading.equalTo(self.safeInset.left)
            $0.trailing.equalTo(-self.safeInset.right)
            $0.top.equalTo(self.statusHeight + self.naviHeight)
            $0.bottom.equalTo(-self.safeInset.bottom)
            $0.width.lessThanOrEqualTo(limitWidth).priority(.required)
            $0.centerX.equalToSuperview().priority(.required)
        }
        makeConst(pageControl) {
            $0.leading.equalTo(self.safeInset.left + self.mainSize.width * 0.25)
            $0.trailing.equalTo(-(self.safeInset.right + self.mainSize.width * 0.25))
            $0.bottom.equalTo(-(self.safeInset.bottom + self.minSize * 0.0266))
        }
    }
    
    // Orientation 대응
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let prevIndex = round(listView.contentOffset.x / listView.bounds.width)
        func setContentOffset() {
            let offset = CGPoint(x: prevIndex * listView.bounds.width, y: 0)
            listView.setContentOffset(offset, animated: false)
        }
        coordinator.animateAlongsideTransition(in: nil, animation: { _ in
            self.listView.collectionViewLayout.invalidateLayout()
            setContentOffset()
        }, completion: { _ in
            self.listView.reloadData()
            setContentOffset()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listView.reloadData()
        listView.collectionViewLayout.invalidateLayout()
        initToolBar()
        updateSelection()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _ = dispatchOnce
    }
    
    /// One time dispatch code.
    private lazy var dispatchOnce: Void = {
        // Data load가 없을때, 화면을 전체 폴더로 이동시킨다.
        listView.setContentOffset(CGPoint(x: listView.bounds.width - 1, y: 0), animated: false)
        listView.setContentOffset(CGPoint(x: listView.bounds.width, y: 0), animated: true)
        navi { (_, item) in
            item.leftBarButtonItem?.title = "manageFolder".locale
            item.rightBarButtonItem?.title = "select".locale
            item.titleView = makeView(UILabel()) {
                $0.font = UIFont.preferred(font: 17, weight: .semibold)
                $0.text = "둘러보기"
                $0.alpha = 0
            }
        }
    }()
    
    /// ToolbarItems 설정
    private func initToolBar() {
        navi { (navi, _) in
            navi.toolbarItems = toolbarItems
            // toolbarItems array 순서 = [item, <-spacer->, item, <-spacer->, item]
            guard let toolbarItems = navigationController?.toolbarItems?[2] else {return}
            toolbarItems.title = "moveToNext".locale
        }
    }
    
    @IBAction private func naviBar(left item: UIBarButtonItem) {
        if item.title! == "manageFolder".locale {
            
            guard let vc = UIStoryboard(name: "Category", bundle: nil).instantiateInitialViewController() else {return}
            
            present(vc, animated: true, completion: nil)
        } else {
            if let cell = listView.visibleCells.first as? DRContentFolderCell {
                let indexData = cell.data.enumerated().flatMap { (section, data) in
                    data.enumerated().map { (row, _) in
                        IndexPath(row: row, section: section)
                    }
                }
                cell.selectedIndex.removeAll()
                indexData.forEach {cell.selectedIndex.append($0)}
                for cell in cell.listView.visibleCells as! [DRContentNoteCell] {
                    cell.select = true
                    cell.setNeedsLayout()
                }
            }
        }
    }
    
    private func validateToken() {
        do {
            let realm = try Realm()
            
            if let existingTags = realm.objects(RealmTagsModel.self).first {
                tags = existingTags
            } else {
                let newTags = RealmTagsModel.getNewModel()
                ModelManager.saveNew(model: newTags) { [weak self] _ in
                    DispatchQueue.main.sync {
                        self?.validateToken()
                    }
                }
                return
            }
            
            notificationToken = tags?.observe { [weak self] (changes) in
                guard let collectionView = self?.listView else {return}
                
                switch changes {
                case .deleted: break
                case .change(_): collectionView.reloadData()
                case .error(let error): print(error)
                }
            }
            // Data load가 진행된 이후, 화면을 전체 폴더로 이동시킨다.
            listView.reloadData()
            listView.setContentOffset(CGPoint(x: listView.bounds.width - 1, y: 0), animated: false)
            listView.setContentOffset(CGPoint(x: listView.bounds.width, y: 0), animated: true)
        } catch {print(error)}
    }
    
    /// 해당 folder의 note count에 따라서 "선택" 버튼을 활성화한다.
    private func updateSelection() {
        guard let indexPath = listView.indexPathsForVisibleItems.first else {return}
        guard let realm = try? Realm() else {return}
        var tagsArray = tags?.tags.components(separatedBy: RealmTagsModel.tagSeparator) ?? []
        if !tagsArray.isEmpty {
            tagsArray.replaceSubrange(Range<Int>(NSMakeRange(0, 1))!, with: ["모든 메모"])
        }
        tagsArray.insert("둘러보기", at: 0)
        let sortDescriptors = [SortDescriptor(keyPath: "isPinned", ascending: false), SortDescriptor(keyPath: "isModified", ascending: false)]
        var notes: Results<RealmNoteModel>!
        if tagsArray[indexPath.item] == "모든 메모" {
            notes = realm.objects(RealmNoteModel.self).filter("isInTrash = false").sorted(by: sortDescriptors)
        } else {
            notes = realm.objects(RealmNoteModel.self)
                .filter("tags CONTAINS[cd] %@ AND isInTrash = false", RealmTagsModel.tagSeparator + tagsArray[indexPath.item] + RealmTagsModel.tagSeparator).sorted(by: sortDescriptors)
        }
        guard let rightItem = navigationItem.rightBarButtonItem else {return}
        rightItem.isEnabled = !notes.isEmpty
    }
    
    @IBAction private func naviBar(right item: UIBarButtonItem) {
        if let _ = listView.visibleCells.first as? DRBrowseFolderCell {
            
        } else if let cell = listView.visibleCells.first as? DRContentFolderCell {
            listView.isScrollEnabled = !listView.isScrollEnabled
            cell.isEditMode = !listView.isScrollEnabled
            navi { (navi, item) in
                navi.isToolbarHidden = listView.isScrollEnabled
                item.leftBarButtonItem?.title = "\(listView.isScrollEnabled ? "manageFolder" :"selectAll")".locale
                item.rightBarButtonItem?.title = "\(listView.isScrollEnabled ? "select" :"done")".locale
            }
            guard let headerView = cell.listView.tableHeaderView else {return}
            cell.listView.contentInset.top = listView.isScrollEnabled ? 0 : -headerView.bounds.height
            headerView.isHidden = !listView.isScrollEnabled
            updateSelection()
        }
    }
    
    @IBAction private func toolBar(left item: UIBarButtonItem) {
        
    }
    
    @IBAction private func toolBar(center item: UIBarButtonItem) {
        guard let vc = UIStoryboard(name: "Category", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let categoryVC = vc.topViewController as? CategoryManageViewController else {return}
        categoryVC.isForMoving = true
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func toolBar(right item: UIBarButtonItem) {
        if let cell = listView.visibleCells.first as? DRContentFolderCell {
            alertWithOKAction(message: "선택하신 노트를 삭제하시겠습니까?") { [weak cell] _ in
                cell?.deleteSelectedCells()
            }
        }
    }
    
}

extension MainListViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 화면 중앙점을 기준으로 index를 계산한다.
        let centerOffset = CGPoint(x: scrollView.contentOffset.x + scrollView.center.x, y: scrollView.center.y)
        guard let indexPath = listView.indexPathForItem(at: centerOffset) else {return}
        pageControl.currentPage = indexPath.row
        initNavi(item: indexPath)
    }
    
    /**
     navigationItem의 title 및 image를 설정한다.
     - parameter indexPath : 현재 보이지는 cell의 indexPath.
     */
    private func initNavi(item indexPath: IndexPath) {
        guard let titleView = navigationItem.titleView as? UILabel else {return}
        var tagsArray = tags?.tags.components(separatedBy: RealmTagsModel.tagSeparator) ?? []
        if !tagsArray.isEmpty {
            tagsArray.replaceSubrange(Range<Int>(NSMakeRange(0, 1))!, with: ["모든 메모"])
        }
        tagsArray.insert("둘러보기", at: 0)
        
        titleView.text = tagsArray[indexPath.item]
        titleView.sizeToFit()
        guard let rightItem = navigationItem.rightBarButtonItem else {return}
        rightItem.title = (indexPath.item == 0) ? "" : "select".locale
        updateSelection()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 폴더간 이동시 노트 리스트를 처음 위치로 초기화 시킨다.
        if let browseFolderCell = cell as? DRBrowseFolderCell {
            browseFolderCell.listView.setContentOffset(.zero, animated: false)
        }
        if let contentFolderCell = cell as? DRContentFolderCell {
            contentFolderCell.listView.setContentOffset(.zero, animated: false)
        }
        // 폴더간 이동시 navigation titleView의 alpha값을 초기화 시킨다.
        destIndexPath = indexPath
        guard let titleView = navigationItem.titleView as? UILabel else {return}
        titleViewAlpha = titleView.alpha
        titleView.alpha = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 기존의 cell로 다시 돌아왔다면 alpha값 복원.
        guard let titleView = navigationItem.titleView as? UILabel else {return}
        titleView.alpha = (destIndexPath == indexPath) ? titleViewAlpha : 0
    }
    
}

extension MainListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

extension MainListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = tags?.tags.components(separatedBy: RealmTagsModel.tagSeparator).count ?? 0
        pageControl.numberOfPages = count + 1
        return count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRBrowseFolderCell", for: indexPath) as! DRBrowseFolderCell
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DRContentFolderCell", for: indexPath) as! DRContentFolderCell
        
        var tagsArray = tags?.tags.components(separatedBy: RealmTagsModel.tagSeparator) ?? []
        tagsArray.insert("둘러보기", at: 0)
        cell.tagName = tagsArray[indexPath.item].replacingOccurrences(of: RealmTagsModel.lockSymbol, with: "")
        cell.lockView.isHidden = !tagsArray[indexPath.item].hasPrefix(RealmTagsModel.lockSymbol)
        
        return cell
    }
    
}

