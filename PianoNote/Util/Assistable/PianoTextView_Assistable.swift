//
//  PianoTextView_Assistable.swift
//  AssistView
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation

extension PianoTextView {
    @objc func newline(sender: KeyCommand) {
        replaceProcess()
    }
    
    @objc func escape(sender: KeyCommand) {
        hideAssistViewIfNeeded()
    }
    
    @objc func upArrow(sender: KeyCommand) {
        
        guard let tableView = subView(viewTag: ViewTag.PianoAssistTableView) as? PianoAssistTableView,
            let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.row == 0 {
            newIndexPath = IndexPath(row: numberOfRows - 1, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.row - 1, section: 0)
        }
        
        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .none)
        
    }
    
    @objc func downArrow(sender: KeyCommand) {
        
        guard let tableView = subView(viewTag: ViewTag.PianoAssistTableView) as? PianoAssistTableView,
            let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.row + 1 == numberOfRows {
            newIndexPath = IndexPath(row: 0, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.row + 1, section: 0)
        }
        
        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .none)
        
    }
}
