//
//  PianoCard.swift
//  InteractiveTextEngine_iOS
//
//  Created by Kevin Kim on 27/04/2018.
//
import Foundation

struct PianoCard {
    //TODO: regexs localized ex: regexString.localized
    private let regexs: [(type: PianoCardType, regex: String)] = [
        (.images, "^\\s*(#사진\\s*)(?=)"),
        (.url, "^\\s*(#링크\\s*)(?=)"),
        (.address, "^\\s*(#주소\\s*)(?=)"),
        (.contact, "^\\s*(#연락처\\s*)(?=)"),
        (.file, "^\\s*(#파일\\s*)(?=)"),
        (.calendar, "^\\s*(#일정\\s*)(?=)"),
        (.reminders, "^\\s*(#미리알림\\s*)(?=)")
    ]
    
    // replace해야하는 범위: 문단의 맨 앞 위치 <= 범위 <=커서의 위치
    
    
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
    public func attachment() -> InteractiveTextAttachment {
        
        return InteractiveTextAttachment()
    }
}
