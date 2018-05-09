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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.cornerRadius = 6
        layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
