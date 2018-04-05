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
    @IBOutlet weak var lockImageView: UIImageView!
    weak var delegate: CategoryManageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nameTouched))
        titleLabel.addGestureRecognizer(gestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

    @objc func nameTouched() {
        if let myTitle = titleLabel.text {
            delegate?.nameTouched(name: myTitle)
        }
    }
}


protocol CategoryManageCellDelegate: AnyObject {
    func nameTouched(name: String)
}
