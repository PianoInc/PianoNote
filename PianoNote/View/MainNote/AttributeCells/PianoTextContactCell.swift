//
//  PianoTextContactCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class PianoTextContactCell: InteractiveAttachmentCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor(hex6: "E9E9E9").cgColor
        layer.cornerRadius = 10.0
        
        imageView.layer.cornerRadius = 5.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with attribute: AttachmentAttribute) {
        if case let .contact(contactAttribute) = attribute {
            titleLabel.text = contactAttribute.name
            contactLabel.text = contactAttribute.contact
            imageView.setImage(with: contactAttribute.name, circular: true)
        }
    }
}
