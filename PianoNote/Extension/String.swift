//
//  String.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 23..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit


extension Range where Bound == String.Index {
    func toNSRange() -> NSRange {
        return NSMakeRange(lowerBound.encodedOffset, upperBound.encodedOffset - lowerBound.encodedOffset)
    }
}

extension String {
    
    var nsString: NSString {
        return NSString(string: self)
    }
    
    /// 해당 id를 가지는 localized string을 반환한다.
    var locale: String {
        return NSLocalizedString(self, comment: self)
    }
    
    /**
     앞에서부터 해당 문자열의 index를 검출한다.
     - parameter of : 해당 문자열.
     - returns : 검출된 index.
     */
    func index(of: String) -> Int {
        guard let range = range(of: of) else {return 0}
        return distance(from: startIndex, to: range.lowerBound)
    }
    
    /**
     뒤에서부터 해당 문자열의 index를 검출한다.
     - parameter of : 해당 문자열.
     - returns : 검출된 index.
     */
    func index(lastOf: String) -> Int {
        guard let range = range(of: lastOf, options: .backwards) else {return 0}
        return distance(from: startIndex, to: range.upperBound)
    }
    
    /**
     주어진 range의 substring을 반환한다.
     - parameter r : from...to
     */
    func sub(_ r: CountableClosedRange<Int>) -> String {
        return substring(r.lowerBound..<r.upperBound)
    }
    
    /**
     주어진 range의 substring을 반환한다.
     - parameter r : from...
     */
    func sub(_ r: CountablePartialRangeFrom<Int>) -> String {
        return substring(r.lowerBound..<count)
    }
    
    /**
     주어진 range의 substring을 반환한다.
     - parameter r : ...to
     */
    func sub(_ r: PartialRangeThrough<Int>) -> String {
        return substring(0..<r.upperBound)
    }
    
    /// Substring 계산 함수.
    private func substring(_ r: CountableRange<Int>) -> String {
        let from = (r.startIndex > 0) ? index(startIndex, offsetBy: r.startIndex) : startIndex
        let to = (count > r.endIndex) ? index(startIndex, offsetBy: r.endIndex) : endIndex
        guard from >= startIndex && to <= endIndex else {return self}
        return String(self[from..<to])
    }
    
    /**
     해당 String이 가지는 boundingRect중에서 height값을 반환한다.
     - parameter width: 계산에 사용될 width.
     - parameter point: 계산에 사용될 font point size.
     - returns: 주어진 data를 통해 계산된 height값.
     */
    func boundingRect(with width: CGFloat, font point: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let set: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let font = [NSAttributedStringKey.font : UIFont.preferred(font: point, weight: .regular)]
        let contentSize = self.boundingRect(with: size, options: set, attributes: font, context: nil)
        return contentSize.height
    }
    
}

extension NSAttributedString {
    
    /**
     해당 String을 width값으로 제한하여 첫번째 줄만큼을 반환한다.
     - parameter width : 제한하고자 하는 width값.
     - returns : 첫번째줄에 해당하는 text.
     */
    func firstLine(width: CGFloat) -> NSAttributedString {
        let frameSetter = CTFramesetterCreateWithAttributedString(self)
        let maxWidth = CGFloat.greatestFiniteMagnitude
        let rect =  CGRect(x: 0, y: 0, width: width, height: maxWidth)
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        guard let line = (CTFrameGetLines(frame) as! [CTLine]).first else {
            return NSAttributedString(string: "")
        }
        return attributedSubstring(from: NSMakeRange(0, CTLineGetStringRange(line).length))
    }
    
    func withoutParagraphStyle() -> NSAttributedString {
        
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = ParagraphStyle()
        if mutableAttrString.length != 0 {
            mutableAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, mutableAttrString.length))
        }
        return mutableAttrString
        
    }
    
    func getStringWithPianoAttributes() -> (string: String, attributes: [AttributeModel]) {
        var attributes: [AttributeModel] = []
        
        self.enumerateAttributes(in: NSMakeRange(0, self.length), options: .reverse) { (dic, range, _) in
            for (key, value) in dic {
                if let pianoAttribute = AttributeModel(range: range, attribute: (key, value)) {
                    attributes.append(pianoAttribute)
                }
            }
        }
        
        return (string: self.string, attributes: attributes)
    }
    
}

extension UILabel {
    
    /// Label의 첫번째 줄에 있는 Text를 반환한다.
    var firstLineText: String {
        guard let text = text, let font = font else {return ""}
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttributes([NSAttributedStringKey.font : font], range: NSMakeRange(0, attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr)
        let maxWidth = CGFloat.greatestFiniteMagnitude
        let rect =  CGRect(x: 0, y: 0, width: bounds.size.width, height: maxWidth)
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        guard let line = (CTFrameGetLines(frame) as! [CTLine]).first else {return ""}
        return text.sub(0...CTLineGetStringRange(line).length)
    }
    
}

extension UITextView {
    
    typealias WordRange = (word: String, range: UITextRange)
    
    /**
     해당 point와 맞닿고 있는 WordRange를 반환한다.
     - parameter point : 찾고자 하는 point.
     - returns : 해당 point에 있는 word와 range.
     */
    func word(from point: CGPoint) ->  WordRange? {
        guard let position = closestPosition(to: point) else {return nil}
        if let range = tokenizer.rangeEnclosingPosition(position, with: .word, inDirection: 1) {
            if let text = text(in: range) {return WordRange(word: text, range: range)}
        }
        if let range = tokenizer.rangeEnclosingPosition(position, with: .word, inDirection: 2) {
            if let text = text(in: range) {return WordRange(word: text, range: range)}
        }
        return nil
    }
    
}

