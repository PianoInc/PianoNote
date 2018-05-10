//
//  PianoCard.swift
//  InteractiveTextEngine_iOS
//
//  Created by Kevin Kim on 27/04/2018.
//

import Foundation

struct PianoCard {
    
    static let keywords = ["사진", "링크", "주소", "연락처", "파일", "일정", "미리알림"]

    //TODO: regexs localized ex: regexString.localized
    private let regexs: [(type: PianoCardType, regex: String)] = [
        (.images, "^\\s*(#\(PianoCard.keywords[0])\\s*)(?=)"),
        (.url, "^\\s*(#\(PianoCard.keywords[1])\\s*)(?=)"),
        (.address, "^\\s*(#\(PianoCard.keywords[2])\\s*)(?=)"),
        (.contact, "^\\s*(#\(PianoCard.keywords[3])\\s*)(?=)"),
        (.file, "^\\s*(#\(PianoCard.keywords[4])\\s*)(?=)"),
        (.calendar, "^\\s*(#\(PianoCard.keywords[5])\\s*)(?=)"),
        (.reminders, "^\\s*(#\(PianoCard.keywords[6])\\s*)(?=)")
    ]
    
    enum PianoCardType {
        case images
        case url
        case address
        case contact
        case file
        case calendar
        case reminders
    }
    
    init?(text: String, selectedRange: NSRange) {
        let nsText = text as NSString
        let paraRange = nsText.paragraphRange(for: selectedRange)
        let searchRange = NSMakeRange(paraRange.location, selectedRange.location - paraRange.location)
        
        for (type, regex) in regexs {
            if let (_, range) = text.detect(searchRange: searchRange, regex: regex) {
                self.range = range
                self.type = type
                self.textRange = NSMakeRange(range.location + range.length,
                                             selectedRange.location - (range.location + range.length))
                return
            }
        }
        
        return nil
    }
    
    public let range: NSRange
    public let textRange: NSRange
    public let type: PianoCardType
    
    
    //TODO: 이부분 만들어야함
//    public func attachment() -> InteractiveTextAttachment {
//        
//        return InteractiveTextAttachment()
//    }
}
