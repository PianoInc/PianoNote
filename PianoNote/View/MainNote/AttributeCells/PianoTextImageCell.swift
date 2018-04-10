//
//  PianoTextImageCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class PianoTextImageCell: InteractiveAttachmentCell, AttributeModelConfigurable {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    //Note: This scope has no responsibility for reload logic
    func configure(with attribute: AttachmentAttribute) {
        if case let .image(imageAttribute) = attribute {
            if let image = LocalImageCache.shared.getImage(id: imageAttribute.id + "thumb") {
                imageView.image = image
            }
        }
    }
    
}
