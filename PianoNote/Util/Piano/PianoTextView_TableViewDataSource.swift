//
//  PianoTextView_TableViewDataSource.swift
//  PianoNote
//
//  Created by Kevin Kim on 09/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

extension PianoTextView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PianoAssistTableViewCell.reuseIdentifier) as! PianoAssistTableViewCell
        configure(cell, indexPath: indexPath)
        return cell
    }
    
    private func configure(_ cell: PianoAssistTableViewCell, indexPath: IndexPath) {
        cell.titleLabel.text = matchedKeywords[indexPath.row].keyword
        //        cell.subTitleLabel.text = matchedKeywords[indexPath.row].subKeyword
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchedKeywords.count
    }
}

extension PianoTextView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        replaceProcess()
    }
}
