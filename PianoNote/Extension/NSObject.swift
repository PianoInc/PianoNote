//
//  NSObject.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 17..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation

extension NSObject {
    static func unarchieve(from data: Data) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }
    
    func archieve() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}
