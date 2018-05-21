//
//  PianoBullet.swift
//  PianoNote
//
//  Created by Kevin Kim on 2018. 2. 23..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation

//TODO: Copy-on-Write 방식 책 보고 구현하기
public struct PianoBullet {
    
    public enum PianoBulletType: Int {
        case number
        case key
        case value
    }
    
    static var customBullet: [String : String] = ["1":"■", "2": "□", "3": "•", "4": "◦"]
    static let customKeys: String = {
        var keys = ""
        for key in PianoBullet.customBullet.keys {
            keys.append(key)
        }
        return keys
    }()
    
    static let customValues: String = {
       var values = ""
        for value in PianoBullet.customBullet.values {
            values.append(value)
        }
        return values
    }()
    
    private let regexs: [(type: PianoBulletType, regex: String)] = [
        (.number, "^\\s*(\\d+)(?=\\. )"),
        (.key, "^\\s*([\(PianoBullet.customKeys)])(?= )"),
        (.value, "^\\s*([\(PianoBullet.customValues)])(?= )")
    ]
    
    public let type: PianoBulletType
    public let whitespaces: (string: String, range: NSRange)
    public let string: String
    public let range: NSRange
    public let paraRange: NSRange
    
    
    public var baselineIndex: Int {
        return range.location + range.length + (type != .number ? 1 : 2)
    }
    
    public var isOverflow: Bool {
        return range.length > 20
    }
    
    public var converted: String? {
        switch type {
        case .number:
            return string
        case .key:
            return PianoBullet.customBullet[string]
        case .value:
            return PianoBullet.customBullet.filter{ $0.value == string }.keys.first
        }
    }
    
    public init?(text: String, selectedRange: NSRange) {
        let nsText = text as NSString
        let paraRange = nsText.paragraphRange(for: selectedRange)
        
        for (type, regex) in regexs {
            if let (string, range) = text.detect(searchRange: paraRange, regex: regex) {
                self.type = type
                self.string = string
                self.range = range
                let wsRange = NSMakeRange(paraRange.location, range.location - paraRange.location)
                let wsString = nsText.substring(with: wsRange)
                self.whitespaces = (wsString, wsRange)
                self.paraRange = paraRange
                return
            }
        }
        
        return nil
    }
    
    /*
     피아노를 위한 line 이니셜라이져
     */
    public init?(text: String, lineRange: NSRange) {
        
        let nsText = text as NSString
        guard nsText.length != 0 else { return nil }
        let paraRange = nsText.paragraphRange(for: lineRange)
        for (type, regex) in regexs {
            if let (string, range) = text.detect(searchRange: lineRange, regex: regex) {
                self.type = type
                self.string = string
                self.range = range
                let wsRange = NSMakeRange(paraRange.location, range.location - paraRange.location)
                let wsString = nsText.substring(with: wsRange)
                self.whitespaces = (wsString, wsRange)
                self.paraRange = paraRange
                return
            }
        }
        
        return nil
    }
    
    public func prevBullet(text: String) -> PianoBullet? {
        
        guard paraRange.location != 0 else { return nil }
        return PianoBullet(text: text, selectedRange: NSMakeRange(paraRange.location - 1, 0))
        
    }
    
    public func isSequencial(next: PianoBullet) -> Bool {
        
        guard let current = UInt(string),
            let next = UInt(next.string) else { return false }
        return current + 1 == next
        
    }
    
}


