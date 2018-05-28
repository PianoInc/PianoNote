//
//  InteractiveAttachmentCell_iOS.swift
//  InteractiveTextEngine
//
//  Created by 김범수 on 2018. 3. 23..
//

import UIKit

open class InteractiveAttachmentCell: UIView {

    let uniqueID = UUID().uuidString
    var reuseIdentifier: String!
    
    weak var relatedAttachment: InteractiveTextAttachment?
    
    var leadingConstraint: NSLayoutConstraint?
    var topConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    func getScreenShot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
