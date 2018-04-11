//
//  String.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 23..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension String {
    
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

