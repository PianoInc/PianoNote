//
//  LinkAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class LinkAttachment: InteractiveTextAttachment, AttributeContainingAttachment {
    static let cellIdentifier = "LinkCell"
    
    var attribute: AttachmentAttribute!
    
    override var identifier: String {
        return LinkAttachment.cellIdentifier
    }

    init(attribute: LinkAttribute) {
        super.init()
        self.attribute = .link(attribute)
        self.currentSize = attribute.size
    }
    
    init(attachment: LinkAttachment) {
        super.init(attachment: attachment)
        self.attribute = attachment.attribute
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return LinkAttachment(attachment: self)
    }
}
