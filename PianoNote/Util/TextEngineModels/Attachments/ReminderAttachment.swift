//
//  ReminderAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import EventKit

class ReminderAttachment: InteractiveTextAttachment, AttributeContainingAttachment {
    var attribute: AttachmentAttribute!

    init(attribute: ReminderAttribute) {
        super.init()
        self.attribute = .reminder(attribute)
        self.currentSize = attribute.size
    }

    init(attachment: ReminderAttachment) {
        super.init(attachment: attachment)
        self.attribute = attachment.attribute
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return ReminderAttachment(attachment: self)
    }
}
