//
//  AddressAttribute.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import CoreGraphics

struct AddressAttribute {
    let placeName: String
    let address: String
    let size: CGSize
}

extension AddressAttribute: Hashable {
    static func ==(lhs: AddressAttribute, rhs: AddressAttribute) -> Bool {
        return lhs.placeName == rhs.placeName && lhs.address == rhs.address && lhs.size == rhs.size
    }
    
    var hashValue: Int {
        return placeName.hashValue ^ address.hashValue ^ size.width.hashValue ^ size.height.hashValue &* 16777619
    }
}

extension AddressAttribute: Codable {
    
    private enum CodingKeys: CodingKey {
        case placeName
        case address
        case size
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        placeName = try values.decode(String.self, forKey: .placeName)
        address = try values.decode(String.self, forKey: .address)
        size = try values.decode(CGSize.self, forKey: .size)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(placeName, forKey: .placeName)
        try container.encode(address, forKey: .address)
        try container.encode(size, forKey: .size)
    }
}
