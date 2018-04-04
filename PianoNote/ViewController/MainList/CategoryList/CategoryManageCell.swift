//
//  CategoryManageCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 4..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class CategoryManageCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

}
