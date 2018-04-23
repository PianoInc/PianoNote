//
//  ContactAttribute.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import CoreGraphics

struct ContactAttribute {
    let name: String
    let contact: String
    let size: CGSize
}

extension ContactAttribute: Hashable {
    static func ==(lhs: ContactAttribute, rhs: ContactAttribute) -> Bool {
        return lhs.name == rhs.name && lhs.contact == rhs.contact && lhs.size == rhs.size
    }
    
    var hashValue: Int {
        return name.hashValue ^ contact.hashValue ^ size.width.hashValue ^ size.height.hashValue &* 16777619
    }
}

extension ContactAttribute: Codable {
    
    private enum CodingKeys: CodingKey {
        case name
        case contact
        case size
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name = try values.decode(String.self, forKey: .name)
        contact = try values.decode(String.self, forKey: .contact)
        size = try values.decode(CGSize.self, forKey: .size)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(contact, forKey: .contact)
        try container.encode(size, forKey: .size)
    }
}
