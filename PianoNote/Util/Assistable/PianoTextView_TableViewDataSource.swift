//
//  NoteViewController_TableViewDataSource.swift
//  PianoNote
//
//  Created by Kevin Kim on 01/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import Highlighter

extension PianoTextView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PianoAssistTableViewCell.reuseIdentifier) as! PianoAssistTableViewCell
        configure(cell, indexPath: indexPath)
        return cell
    }

    private func configure(_ cell: PianoAssistTableViewCell, indexPath: IndexPath) {
        
        cell.titleLabel.text = assistDataSource[indexPath.row].keyword

        let normalAttributes = cell.titleLabel.attributedText?.attributes(at: 0, effectiveRange: nil)
        var highlightAttributes = normalAttributes
        highlightAttributes?[NSAttributedStringKey.backgroundColor] = UIColor.yellow.withAlphaComponent(0.5)

        cell.highlight(text: assistDataSource[indexPath.row].input, normal: normalAttributes, highlight: highlightAttributes)

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assistDataSource.count
    }
}

extension PianoTextView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        replaceProcess()
    }
}
