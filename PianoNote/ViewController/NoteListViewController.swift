//
//  NoteListViewController.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RealmSwift

class NoteListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var results: Results<RealmNoteModel>?
    var notificationToken: NotificationToken?
    var navTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 221
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        
        navigationItem.title = navTitle
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        registerToken()
    }

    deinit {
        notificationToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func registerToken() {
        guard let realm = try? Realm() else {return}

        //tagname is navTitle

        let sortDescriptors = [SortDescriptor(keyPath: "isPinned", ascending: false),
                               SortDescriptor(keyPath: "isModified", ascending: false)]

        let tag = RealmTagsModel.tagSeparator + navTitle + RealmTagsModel.tagSeparator

        if navTitle == "모든 메모" {
            results = realm.objects(RealmNoteModel.self)
                .filter("isInTrash = false", tag)
                .sorted(by: sortDescriptors)
        } else {
            results = realm.objects(RealmNoteModel.self)
                .filter("tags CONTAINS[cd] %@ AND isInTrash = false", tag)
                .sorted(by: sortDescriptors)
        }
        
        //set results

        notificationToken = results?.observe { [weak self] change in
            guard let tableView = self?.tableView else {return}
            switch change {
                case .initial: tableView.reloadData()
                case .update(_, _, _, _):
//                    tableView.beginUpdates()
                    tableView.reloadData()
//                    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//                    tableView.endUpdates()
                case .error(let error):
                    fatalError("Error!! \(error)")
            }
        }

    }
    
    
    

}

extension NoteListViewController: UITableViewDataSource, UITableViewDelegate {

    func isSameGroup(current currentModel: RealmNoteModel, previous previousModel: RealmNoteModel) -> Bool {
        if previousModel.isPinned {
            return currentModel.isPinned
        } else {
            return previousModel.isModified.timeFormat == currentModel.isModified.timeFormat
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (results?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noteListNewCell", for: indexPath) as! NoteListNewCell
            cell.delegate = self
            return cell
        } else {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "noteListCell",
                                     for: indexPath) as! NoteListCell
            cell.cellGestureRecognizer?.delegate = self

            let currentModelIndex = indexPath.row - 1
            guard let results = results else {return cell}
            let currentNoteModel = results[currentModelIndex]

            let isTop = currentModelIndex == 0 || !isSameGroup(current: currentNoteModel, previous: results[currentModelIndex-1])
            let isBottom = currentModelIndex == results.count - 1 || !isSameGroup(current: results[currentModelIndex+1], previous: currentNoteModel)

            cell.configure(isTop: isTop, isBottom: isBottom, currentModel: currentNoteModel)
            cell.delegate = self

            return cell
        }
        
    }
    
}

extension NoteListViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if let noteListGS = gestureRecognizer as? NoteListGestureRecognizer,
            let panGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: tableView)
            
            if abs(velocity.y) > abs(velocity.x) {
                noteListGS.reset()
            }
            return !noteListGS.isActivated
        }
        

        return true
    }
}

extension NoteListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.visibleCells.forEach { cell in
            guard let cell = cell as? NoteListCell else {return}
            cell.cellGestureRecognizer?.reset()
            cell.animateToDefault()
        }
    }
}

extension NoteListViewController: NoteListCellDelegate {
    
    func didTap(noteID: String) {
        guard let vc = UIStoryboard(name: "Main1", bundle: nil)
                .instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController
            else { return }
        
        vc.noteID = noteID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func requestDelete(noteID: String) {
        alertWithOKAction(message: "삭제하시겠습니까?") { (_) in
            ModelManager.update(id: noteID, type: RealmNoteModel.self, kv: [Schema.Note.isInTrash: true])
        }
    }
    
    func requestPin(noteID: String) {
        guard let realm = try? Realm(),
            let currentModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        
        let isPinned = currentModel.isPinned
        let message = !isPinned ? "고정 하시겠습니까?" : "고정 해제 하시겠습니까?"
        alertWithOKAction(message: message) { (_) in
            ModelManager.update(id: noteID, type: RealmNoteModel.self, kv: [Schema.Note.isPinned: !isPinned])
        }
    }
    
    func requestLock(noteID: String) {
        
    }
}

extension NoteListViewController: NoteListNewCellDelegate {
    func didTapNew() {
        let tagName = navTitle == "전체 메모" ? "" : navTitle
        let newModel = RealmNoteModel.getNewModel(content: "", categoryRecordName: tagName)
        let id = newModel.id
        ModelManager.saveNew(model: newModel) { [weak self] _ in
            DispatchQueue.main.async {
                guard let vc = UIStoryboard(name: "Main1", bundle: nil)
                    .instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController
                    else { return }
                
                vc.noteID = id
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
