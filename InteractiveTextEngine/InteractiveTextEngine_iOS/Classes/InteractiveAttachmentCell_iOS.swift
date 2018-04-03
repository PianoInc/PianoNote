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
    let lineFragmentPadding: CGFloat = 8.0
    
    weak var relatedAttachment: InteractiveTextAttachment?
    
    func getScreenShot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
