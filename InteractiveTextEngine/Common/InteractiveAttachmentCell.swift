//
//  InteractiveAttachmentCell.swift
//  InteractiveTextEngine
//
//  Created by 김범수 on 2018. 3. 22..
//

import Foundation

extension InteractiveAttachmentCell {
    
    public func isRelated(to attachment: InteractiveTextAttachment) -> Bool {
        return (relatedAttachment?.uniqueID ?? "") == attachment.uniqueID
    }

    func sync(to bounds: CGRect) {
        guard let superView = superview as? InteractiveTextView else {return}
        let newBounds = bounds.offsetBy(dx: superView.textContainerInset.left,
                                        dy: superView.textContainerInset.top)
                              .insetBy(dx: 1.5, dy: 0)
        
        if newBounds.minX != leadingConstraint!.constant || newBounds.minY != topConstraint!.constant {
            
            DispatchQueue.main.async { [weak self] in
                self?.leadingConstraint?.constant = newBounds.minX
                self?.topConstraint?.constant = newBounds.minY
                self?.widthConstraint?.constant = newBounds.width
                self?.heightConstraint?.constant = newBounds.height

            }
        }
    }
    

    @objc open func prepareForReuse() {
    }
    
    public func changeSize(to size: CGSize) {
        guard let relatedAttachment = relatedAttachment else {return}
        relatedAttachment.currentSize = size
    }
}

