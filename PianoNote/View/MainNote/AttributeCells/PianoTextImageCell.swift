//
//  PianoTextImageCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class PianoTextImageCell: InteractiveAttachmentCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
