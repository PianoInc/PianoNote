//
//  ReminderAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

//**NSAttachment -> TextView에 attribute string넣는 객체

//**Attribute -> Attachment의 datasource. imageID, address -- Cloud sync attachment attribute
//**cell -> 붙는 뷰

import InteractiveTextEngine_iOS
import EventKit

class ReminderAttachment: InteractiveTextAttachment, AttributeContainingAttachment {
    static let cellIdentifier = "ReminderCell"
    
    var attribute: AttachmentAttribute!
    
    override var identifier: String {
        return ReminderAttachment.cellIdentifier
    }

    init(attribute: ReminderAttribute) {
        super.init()
        self.attribute = .reminder(attribute)
        self.currentSize = attribute.size
    }

    //drag
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
