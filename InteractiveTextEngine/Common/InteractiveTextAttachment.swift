//
//  InteractiveTextAttachment.swift
//  InteractiveTextEngine
//
//  Created by 김범수 on 2018. 3. 22..
//

import Foundation

open class InteractiveTextAttachment: NSTextAttachment {

    public let uniqueID = UUID().uuidString // cell dispatcher가 사용하는 unique ID

    private var isVisible = false //현재 텍스트뷰에서 visible한가
    var currentCharacterIndex: Int!// 현재 textview의 character index

    weak var relatedCell: InteractiveAttachmentCell?
    weak var delegate: InteractiveTextAttachmentDelegate?

    //overridable cell reuse identifier
    open var cellIdentifier: String {
        return ""
    }
    
    //Convenience initializer to make drag
    public init() {
        super.init(data: nil, ofType: nil)
    }
    
    //Drag delegate용
    public init(attachment: InteractiveTextAttachment) {
        super.init(data: nil, ofType: nil)
        
        self.delegate = attachment.delegate
        self.currentSize = attachment.currentSize
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //container내에서의 bounds
    var currentBounds: CGRect? {
        didSet {
            if oldValue == nil {
                delegate?.boundsGiven(attachment: self)
            }
            
            guard let myCell = relatedCell,
                    let bounds = currentBounds else {return}
            myCell.sync(to: bounds)
        }
    }
    
    //저희용
    open var currentSize: CGSize! {
        didSet {
            delegate?.invalidateDisplay(range: NSMakeRange(currentCharacterIndex, 1))
        }
    }
    
    //Drag delegate용
    public func getPreviewForDragInteraction() -> UIImage? {
        return relatedCell?.getScreenShot()
    }
    
    open func getCopyForDragInteraction() -> InteractiveTextAttachment {
        return InteractiveTextAttachment(attachment: self)
    }
    
    
    //refactor 되면 좋은부분
    //textview의 visible bounds
    func checkForVisibility(visibleBounds: CGRect) {
        if let currentBounds = currentBounds {
            if currentBounds.intersects(visibleBounds) {
                if !isVisible {
                    isVisible = true
                    delegate?.needToDisplay(attachment: self)
                }
            } else {
                if isVisible {
                    isVisible = false
                    delegate?.needToEndDisplay(attachment: self)
                }
            }
        }
    }

    override open func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return CGRect(x: 0, y: 0, width: currentSize.width, height: currentSize.height)
    }

}

// In order to react to dispatcher Notification
protocol InteractiveTextAttachmentDelegate: AnyObject {
    func needToDisplay(attachment: InteractiveTextAttachment)
    func needToEndDisplay(attachment: InteractiveTextAttachment)
    func invalidateDisplay(range: NSRange)
    func boundsGiven(attachment: InteractiveTextAttachment)
}
