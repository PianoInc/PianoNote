//
//  PianoTextAddressCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class PianoTextAddressCell: InteractiveAttachmentCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
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
    
    func configure(with attribute: PianoAttribute) {
        if case let .attachment(.address(addressAttribute)) = attribute.style {
            
        }
    }
}
