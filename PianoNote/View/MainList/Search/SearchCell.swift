//
//  SearchCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var searchIconView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 9.0
        searchIconView.layer.cornerRadius = 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
