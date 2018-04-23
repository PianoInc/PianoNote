//
//  UIImageView+Letters.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImage(with string: String, color: UIColor? = nil,
                  circular isCircular: Bool, textAttributes: [NSAttributedStringKey: Any]? = nil) {
        guard !string.isEmpty else { return }
        
        let fontSize = bounds.width * 0.42
        let attributes = textAttributes ?? [.font: UIFont.systemFont(ofSize: fontSize), .foregroundColor: UIColor.white]
        
        var displayString = ""
        
        let words = string.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        if !words.isEmpty {
            let firstWord = words.first!
            let lastWord = words.last!
            displayString.append(firstWord.first!)
            if words.count > 1 {
                displayString.append(lastWord.first!)
            }
        }
        
        let backgroundColor = color ?? UIColor.randomColor()
        
        self.image = self.imageSnapshotFromText(text: displayString.uppercased(), backgroundColor: backgroundColor, circular: isCircular, textAttributes: attributes)
    }
    
    private func imageSnapshotFromText(text: String, backgroundColor color: UIColor,
                                       circular isCircular: Bool, textAttributes: [NSAttributedStringKey: Any]?) -> UIImage? {
        let scale = UIScreen.main.scale
        
        var size = bounds.size
        if self.contentMode == .scaleToFill ||
            self.contentMode == .scaleAspectFill ||
            self.contentMode == .scaleAspectFit ||
            self.contentMode == .redraw {
            
            size.width = CGFloat(floorf(Float(size.width * scale))) / scale
            size.height = CGFloat(floorf(Float(size.height * scale))) / scale
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        if isCircular {
            let path = CGPath(ellipseIn: self.bounds, transform: nil)
            context?.addPath(path)
            context?.clip()
        }
        
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let attributedText = NSAttributedString(string: text, attributes: textAttributes)
        let textSize = attributedText.size()
        
        attributedText.draw(in: CGRect(x: bounds.size.width/2 - textSize.width/2,
                             y: bounds.size.height/2 - textSize.height/2,
                             width: textSize.width,
                             height: textSize.height))
        
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return snapshot
    }
}
