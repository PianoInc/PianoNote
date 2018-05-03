//
//  FontAttribute.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

enum FontSizeCategory: String, Hashable {
    case title1 = "title1"
    case title2 = "title2"
    case title3 = "title3"
    case body = "body"
}

extension FontSizeCategory: Codable {
    private enum CodingKeys: String, CodingKey {
        case title1
        case title2
        case title3
        case body
    }

    enum CodingError: Error {
        case decoding(String)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try? values.decode(String.self, forKey: .title1) {
            self = .title1
            return
        }
        if let _ = try? values.decode(String.self, forKey: .title2) {
            self = .title2
            return
        }
        if let _ = try? values.decode(String.self, forKey: .title3) {
            self = .title3
            return
        }
        if let _ = try? values.decode(String.self, forKey: .body) {
            self = .body
            return
        }

        throw CodingError.decoding("Decode Failed!!!")
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .title1: try container.encode("", forKey: .title1)
        case .title2: try container.encode("", forKey: .title2)
        case .title3: try container.encode("", forKey: .title3)
        case .body: try container.encode("", forKey: .body)
        }
    }
}

struct FontTraits: OptionSet {
    let rawValue: Int
    
    static let bold = FontTraits(rawValue: 1 << 0)
    static let italic = FontTraits(rawValue: 1 << 1)
    
    func toSymbolicTraits() -> UIFontDescriptorSymbolicTraits {
        var traits: UIFontDescriptorSymbolicTraits = []
        if self.contains(.bold) {traits.insert(.traitBold)}
        if self.contains(.italic) {traits.insert(.traitItalic)}
        
        return traits
    }
}


public struct PianoFontAttribute: Hashable {
    
    static func standard() -> PianoFontAttribute {
        return PianoFontAttribute(traits: [], sizeCategory: .body)
    }
    public static func ==(lhs: PianoFontAttribute, rhs: PianoFontAttribute) -> Bool {
        return lhs.traits == rhs.traits && lhs.sizeCategory == rhs.sizeCategory
    }
    
    let traits: FontTraits
    let sizeCategory: FontSizeCategory
    
    public var hashValue: Int {
        return traits.rawValue
    }

    public func getFont() -> UIFont {
        
        return FontManager.shared.font(for: self)
    }
}

extension PianoFontAttribute: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case traits
        case sizeCategory
    }
    
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let optionInt = try values.decode(Int.self, forKey: .traits)
        
        self.traits = FontTraits(rawValue: optionInt)
        self.sizeCategory = try values.decode(FontSizeCategory.self, forKey: .sizeCategory)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(traits.rawValue, forKey: .traits)
        try container.encode(sizeCategory, forKey: .sizeCategory)
    }
}
