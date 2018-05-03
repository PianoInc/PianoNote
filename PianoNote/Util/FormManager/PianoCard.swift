//
//  PianoCard.swift
//  InteractiveTextEngine_iOS
//
//  Created by Kevin Kim on 27/04/2018.
//

import Foundation

struct PianoCard {
    
    static let keywords = [
        PianoKeyword(keyword: "사진", subKeyword: "#사진 우리들의 추억(선택사항)"),
        PianoKeyword(keyword: "링크", subKeyword: "#링크 www.naver.com"),
        PianoKeyword(keyword: "주소", subKeyword: "#주소 서울시 강남구 개포2동 166-3번지"),
        PianoKeyword(keyword: "연락처", subKeyword: "#연락처 010-7359-4004 김찬기"),
        PianoKeyword(keyword: "파일", subKeyword: "#파일 학교 과제"),
        PianoKeyword(keyword: "일정", subKeyword: "#일정 목요일 오후 세시 지오와 미팅"),
        PianoKeyword(keyword: "미리알림", subKeyword: "#미리알림 오늘 오후 다섯시 피트니스 가기")
    ]
    

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
    
    // replace해야하는 범위: #부터 <= 범위 <=커서의 위치
    
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
