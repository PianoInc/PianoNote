//
//  PianoSizeInspector.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 25..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

enum PianoNoteSize {
    
    var level: Int {
        switch self {
        case .verySmall: return 0
        case .small: return 1
        case .normal: return 2
        case .large: return 3
        case .veryLarge: return 4
        }
    }
    
    init?(level: Int) {
        switch level {
        case 0: self = .verySmall
        case 1: self = .small
        case 2: self = .normal
        case 3: self = .large
        case 4: self = .veryLarge
        default: return nil
        }
    }
    
    case verySmall
    case small
    case normal
    case large
    case veryLarge
}

class PianoNoteSizeInspector {
    static let shared = PianoNoteSizeInspector()
    private var currentSize: PianoNoteSize = .normal
    
    private init() {}
    
    func set(to size: PianoNoteSize) {
        currentSize = size
    }
    
    func get() -> PianoNoteSize {
        return currentSize
    }
}
