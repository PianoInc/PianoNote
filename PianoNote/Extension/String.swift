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
        if let range = range(of: of) {
            return distance(from: startIndex, to: range.lowerBound)
        }
        return 0
    }
    
    /**
     뒤에서부터 해당 문자열의 index를 검출한다.
     - parameter of : 해당 문자열.
     - returns : 검출된 index.
     */
    func index(lastOf: String) -> Int {
        if let range = range(of: lastOf, options: .backwards, range: nil, locale: nil) {
            return distance(from: startIndex, to: range.upperBound)
        }
        return 0
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
        if from >= startIndex && to <= endIndex {
            return String(self[from..<to])
        }
        return self
    }
    
}

extension UILabel {
    
    /// Label의 첫번째 줄에 있는 Text를 반환한다.
    var firstLineText: String {
        guard let text = text, let font = font else {return ""}
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttributes([NSAttributedStringKey.font : font], range: NSMakeRange(0, attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: bounds.size.width, height: maxSize), transform: nil)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        guard let line = (CTFrameGetLines(frame) as! [CTLine]).first else {return ""}
        return text.sub(0...CTLineGetStringRange(line).length)
    }
    
}
