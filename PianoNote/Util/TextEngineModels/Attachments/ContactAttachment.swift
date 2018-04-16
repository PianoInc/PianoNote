//
//  ContactAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class ContactAttachment: InteractiveTextAttachment, AttributeContainingAttachment{
    var attribute: AttachmentAttribute!

    init(attribute: ContactAttribute) {
        super.init()
        self.attribute = .contact(attribute)
        self.currentSize = attribute.size
    }
    
    init(attachment: ContactAttachment) {
        super.init(attachment: attachment)
        self.attribute = attachment.attribute
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return ContactAttachment(attachment: self)
    }
}
