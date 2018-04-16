//
//  AddressAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class AddressAttachment: InteractiveTextAttachment, AttributeContainingAttachment {
    var attribute: AttachmentAttribute!

    init(attribute: AddressAttribute) {
        super.init()
        self.currentSize = attribute.size
        self.attribute = .address(attribute)
    }

    init(attachment: AddressAttachment) {
        super.init(attachment: attachment)
        self.attribute = attachment.attribute
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return AddressAttachment(attachment: self)
    }
}
