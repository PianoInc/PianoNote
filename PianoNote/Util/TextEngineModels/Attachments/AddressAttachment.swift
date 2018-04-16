//
//  AddressAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class AddressAttachment: InteractiveTextAttachment {
    static let cellIdentifier = "AddressCell"
    var address: String!

    override var identifier: String {
        return AddressAttachment.cellIdentifier
    }

    override init() {
        super.init()
    }


    
    init(attribute: AddressAttribute) {
        super.init()
        self.address = attribute.address
        self.currentSize = attribute.size
    }
    
    init(attachment: AddressAttachment) {
        super.init(attachment: attachment)
        self.address = attachment.address
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return AddressAttachment(attachment: self)
    }
}
