//
//  EventAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import EventKit

class EventAttachment: InteractiveTextAttachment, AttributeContainingAttachment {
    var attribute: AttachmentAttribute!

    init(attribute: EventAttribute) {
        super.init()
        self.attribute = .event(attribute)
        self.currentSize = attribute.size
    }
    
    init(attachment: EventAttachment) {
        super.init(attachment: attachment)
        self.attribute = attribute
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return EventAttachment(attachment: self)
    }
}
