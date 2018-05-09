//
//  NoteListNewCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class NoteListNewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    weak var delegate: NoteListNewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGS = UITapGestureRecognizer.init(target: self, action: #selector(didTap))
        backView.addGestureRecognizer(tapGS)
        
        backView.layer.cornerRadius = 6
        layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    @objc func didTap() {
        delegate?.didTapNew()
    }
}

protocol NoteListNewCellDelegate: class {
    func didTapNew()
}
