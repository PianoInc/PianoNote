//
//  CardAttachment.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 18..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class CardAttachment: InteractiveTextAttachment {

    private var privateCellIdentifier = ""

    var idForModel = ""

    override var cellIdentifier: String {
        return privateCellIdentifier
    }

    init(idForModel: String, cellIdentifier: String) {
        super.init()

        if cellIdentifier.contains("|") {
            fatalError("identifier should not contain | character")
        }

        self.idForModel = idForModel
        self.privateCellIdentifier = cellIdentifier
        self.currentSize = size(forIdentifier: cellIdentifier)
    }

    init(attachment: CardAttachment) {
        super.init(attachment: attachment)
        self.idForModel = attachment.idForModel
        self.privateCellIdentifier = attachment.cellIdentifier
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///This is a substitution of copy() function. It's used when dragging cell
    override func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return CardAttachment(attachment: self)
    }

    ///Set size for attachment!
    private func size(forIdentifier identifier: String) -> CGSize {
        let width = self.minSize
        let height: CGFloat

        switch identifier {
            default: height = 100
        }

        return CGSize(width: width, height: height)
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

