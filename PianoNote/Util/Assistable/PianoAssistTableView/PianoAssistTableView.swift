//
//  PianoAssistTableView.swift
//  PianoNote
//
//  Created by Kevin Kim on 30/04/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class PianoAssistTableView: UITableView {
    
    let width: CGFloat = 150
    let margin: CGFloat = 10
    let cellHeight: CGFloat = 40
    let minimumHeight: CGFloat = 130
    
    internal func setPosition(textView: UITextView, at caretRect: CGRect) {
        
        //가로 좌표 결정
        if textView.frame.width - caretRect.origin.x <= width {
            self.frame.origin.x = textView.frame.width - (width + margin)
        } else {
            self.frame.origin.x = caretRect.origin.x
        }
        
        //세로 좌표 + 높이 결정
        let heightBelowCaret = textView.frame.height - (caretRect.origin.y - textView.contentOffset.y + caretRect.height)
        
        if heightBelowCaret > minimumHeight {
            
            self.frame.origin.y = caretRect.origin.y + caretRect.height
            self.frame.size.height = min(cellHeight * CGFloat(numberOfRows(inSection: 0)), heightBelowCaret)
            
        } else {
            
            self.frame.size.height = min(cellHeight * CGFloat(numberOfRows(inSection: 0)), caretRect.origin.y - textView.contentOffset.y)
            self.frame.origin.y = caretRect.origin.y - self.frame.size.height
            
        }
        
        self.frame.size.width = width
        
    }
    
    internal func setup(assistable: Assistable & UITableViewDataSource & UITableViewDelegate) {
        
        let cellNib = UINib(nibName: PianoAssistTableViewCell.reuseIdentifier, bundle: nil)
        register(cellNib, forCellReuseIdentifier: PianoAssistTableViewCell.reuseIdentifier)
        dataSource = assistable
        delegate = assistable
        reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }


}
