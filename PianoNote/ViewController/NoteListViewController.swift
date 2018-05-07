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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 221
        
        registerToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func registerToken() {
        guard let realm = try? Realm() else {return}
        //set results
        //TODO: sort it
//        notificationToken = realm.objects(RealmNoteModel.self).observe { (change) in
//            switch change {
//                case .initial(<#T##CollectionType#>)
//            }
//        }
    }
    
    

}

extension NoteListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6//(results?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "noteListNewCell", for: indexPath)
        } else {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "noteListCell",
                                     for: indexPath) as! NoteListCell
            cell.cellGestureRecognizer?.delegate = self
            //TODO: configure cells
            
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
