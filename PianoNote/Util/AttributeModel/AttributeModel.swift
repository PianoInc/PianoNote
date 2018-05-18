//
//  PianoAttribute.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation
import UIKit
import InteractiveTextEngine_iOS

struct AttributeModel {
    let startIndex: Int
    let endIndex: Int
    
    let style: Style
    
    init?(range: NSRange, attribute: (NSAttributedStringKey, Any)) {
        self.startIndex = range.location
        self.endIndex = range.location + range.length
        
        guard let style = Style(from: attribute) else {return nil}
        self.style = style
    }
}

extension AttributeModel: Hashable {
    var hashValue: Int {
        return startIndex.hashValue ^ endIndex.hashValue ^ style.hashValue
    }
    
    static func ==(lhs: AttributeModel, rhs: AttributeModel) -> Bool {
        return lhs.startIndex == rhs.startIndex && lhs.endIndex == rhs.endIndex && lhs.style == rhs.style
    }
    
    
}

extension AttributeModel: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case startIndex = "s"
        case endIndex = "e"
        
        case style = "st"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        startIndex = try values.decode(Int.self, forKey: .startIndex)
        endIndex = try values.decode(Int.self, forKey: .endIndex)
        
        style = try values.decode(Style.self, forKey: .style)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(startIndex, forKey: .startIndex)
        try container.encode(endIndex, forKey: .endIndex)
        
        try container.encode(style, forKey: .style)
    }
}

extension NSMutableAttributedString {
    func add(attribute: AttributeModel) {
        let range = NSMakeRange(attribute.startIndex, attribute.endIndex - attribute.startIndex)
        
        self.addAttributes(attribute.style.toNSAttribute(), range: range)
    }
    
    func delete(attribute: AttributeModel) {
        let range = NSMakeRange(attribute.startIndex, attribute.endIndex - attribute.startIndex)
        
        self.removeAttribute(attribute.style.toNSAttribute().keys.first!, range: range)
    }
}

enum Style {
    case highlight
    case foregroundColor//point
    case strikethrough
    case underline
    case font(PianoFontAttribute)
    case paragraphStyle(Int, String, Int, Int)//bullet type, bullet string, space count ,tab count
    case attachment(AttachmentAttribute)

    init?(from attribute: (key: NSAttributedStringKey, value: Any)) {
        switch attribute.key {
        case .backgroundColor:
            guard let color = attribute.value as? UIColor,
                    color == ColorManager.shared.highlightBackground() else {return nil}
            
            self = .highlight
        case .foregroundColor:
            guard let color = attribute.value as? UIColor ,
                    color == ColorManager.shared.pointForeground() else {return nil}
            self = .foregroundColor
        case .strikethroughStyle:
            guard let value = attribute.value as? Int, value == 1 else {return nil}
            self = .strikethrough
        case .underlineStyle:
            guard let value = attribute.value as? Int, value == 1 else {return nil}
            self = .underline
        case .font:
            guard let font = attribute.value as? UIFont,
                    FontManager.shared.fontAttribute(for: font) != PianoFontAttribute.standard() else {return nil}
            self = .font(FontManager.shared.fontAttribute(for: font))
        case .attachment:
            guard let attachment = attribute.value as? InteractiveTextAttachment & AttributeContainingAttachment,
                let attribute = AttachmentAttribute(attachment: attachment) else {return nil}
            self = .attachment(attribute)

        case .paragraphStyle:
            guard let paragraphStyle = attribute.value as? DynamicParagraphStyle,
                    paragraphStyle != DynamicParagraphStyle.defaultStyle else {return nil}
            self = .paragraphStyle(paragraphStyle.bulletType.rawValue, paragraphStyle.bulletString, paragraphStyle.spaceCount, paragraphStyle.tabCount)

        default: return nil
        }
    }
    
    func toNSAttribute() -> [NSAttributedStringKey: Any] {
        switch self {
        case .highlight: return [.backgroundColor: ColorManager.shared.highlightBackground()]
        case .foregroundColor: return [.foregroundColor: ColorManager.shared.pointForeground()]
        case .strikethrough: return [.strikethroughStyle: 1, .strikethroughColor: ColorManager.shared.underLine()]
        case .underline: return [.underlineStyle: 1, .underlineColor: ColorManager.shared.underLine()]
        case .font(let fontAttribute): return [.pianoFontInfo: fontAttribute, .font: fontAttribute.getFont()]
        case .attachment(let attachmentAttribute): return attachmentAttribute.toNSAttribute()
        case .paragraphStyle(let bulletType, let bulletString, let spaceCount, let tabCount):
            return [.paragraphStyle:
                            DynamicParagraphStyle(bulletType: PianoBullet.PianoBulletType(rawValue: bulletType)!,
                                    bulletString: bulletString, spaceCount: spaceCount, tabCount: tabCount)]

        }
    }
}

extension Style: Hashable {
    var hashValue: Int {
        switch self {
        case .highlight: return "backgroundColor".hashValue
        case .foregroundColor: return "foregroundColor".hashValue
        case .strikethrough: return "strikethrough".hashValue
        case .underline: return "underline".hashValue
        case .font(let fontAttribute): return fontAttribute.hashValue
        case .attachment(let attachmentAttribute): return attachmentAttribute.hashValue
        case .paragraphStyle(let t, let str, let sc, let tc): return t ^ str.hashValue ^ sc ^ tc
        }
    }
    
    static func ==(lhs: Style, rhs: Style) -> Bool {
        switch lhs {
        case .highlight:
            return rhs == .highlight
        case .foregroundColor:
            return rhs == .foregroundColor
        case .strikethrough:
            return rhs == .strikethrough
        case .underline:
            return rhs == .underline
        case .font(let fontAttribute):
            if case let .font(rFontAttribute) = rhs {
                return fontAttribute.hashValue == rFontAttribute.hashValue
            }
            return false
        case .attachment(let attachmentAttribute):
            if case let .attachment(rAttachmentAttribute) = rhs {
                return attachmentAttribute == rAttachmentAttribute
            }
            return false
        case .paragraphStyle(let type, let str, let sc, let tc):
            if case let .paragraphStyle(rType, rStr, rSc, rTc) = rhs {
                return type == rType && str == rStr && sc == rSc && tc == rTc
            }
            return false
        }
    }
    
    
}

extension Style: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case highlight = "bg"
        case foregroundColor = "fg"
        case strikeThrough = "strk"
        case underline = "undr"
        case font = "fnt"
        case attachment = "atch"
        case paragraphStyle = "para"
    }
    
    enum CodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? values.decode(String.self, forKey: .highlight) {
            self = .highlight
            return
        }
        if let _ = try? values.decode(String.self, forKey: .foregroundColor) {
            self = .foregroundColor
            return
        }
        if let _ = try? values.decode(String.self, forKey: .strikeThrough) {
            self = .strikethrough
            return
        }
        if let _ = try? values.decode(String.self, forKey: .underline) {
            self = .underline
            return
        }
        
        if let fontAttribute = try? values.decode(PianoFontAttribute.self, forKey: .font) {
            self = .font(fontAttribute)
            return
        }
        
        if let attachmentAttribute = try? values.decode(AttachmentAttribute.self, forKey: .attachment) {
            self = .attachment(attachmentAttribute)
            return
        }

        if let paraString = try? values.decode(String.self, forKey: .paragraphStyle) {
            let chunks = paraString.components(separatedBy: "|")
            guard chunks.count == 4,
                    let type = Int(chunks[0]),
                    let spaceCount = Int(chunks[2]),
                    let tabCount = Int(chunks[3]) else {throw  CodingError.decoding("Decode Failed!!!")}

            self = .paragraphStyle(type, chunks[1], spaceCount, tabCount)
            return
        }
        
        throw CodingError.decoding("Decode Failed!!!")
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .highlight: try container.encode("", forKey: .highlight)
        case .foregroundColor: try container.encode("", forKey: .foregroundColor)
        case .strikethrough: try container.encode("", forKey: .strikeThrough)
        case .underline: try container.encode("", forKey: .underline)
        case .font(let fontDescriptor): try container.encode(fontDescriptor, forKey: .font)
        case .attachment(let attachmentAttribute): try container.encode(attachmentAttribute, forKey: .attachment)
        case .paragraphStyle(let type, let str, let sc, let tc): try container.encode("\(type)|\(str)|\(sc)|\(tc)", forKey: .paragraphStyle)
        }
    }
}
