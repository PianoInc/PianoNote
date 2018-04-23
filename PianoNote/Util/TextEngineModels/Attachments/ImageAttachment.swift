//
//  ImageAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import UIKit
import CoreGraphics



class ImageAttachment: InteractiveTextAttachment, AttributeContainingAttachment {
    static let cellIdentifier = "ImageCell"
    
    override var identifier: String {
        return ImageAttachment.cellIdentifier
    }
    var attribute: AttachmentAttribute!

    init(attribute: ImageAttribute) {
        super.init()
        self.attribute = .image(attribute)
        self.currentSize = attribute.size
    }
    
    init(attachment: ImageAttachment) {
        super.init(attachment: attachment)
        self.attribute = attachment.attribute
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return ImageAttachment(attachment: self)
    }
}



extension NSTextAttachment {
    func getImage() -> UIImage? {
        if let unwrappedImage = image {
            return unwrappedImage
        } else if let data = contents,
            let decodedImage = UIImage(data: data) {
            return decodedImage
        } else if let fileWrapper = fileWrapper,
            let imageData = fileWrapper.regularFileContents,
            let decodedImage = UIImage(data: imageData) {
            return decodedImage
        }
        return nil
    }
}
