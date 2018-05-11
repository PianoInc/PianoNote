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
    private let key = "sizeKey"
    
    private init() {
        if let level = UserDefaults.standard.value(forKey: key) as? Int,
            let size = PianoNoteSize(level: level) {
            currentSize = size
        }
    }
    
    func set(to size: PianoNoteSize) {
        if size != currentSize {
            defer {
                NotificationCenter.default.post(name: .pianoSizeInspectorSizeChanged, object: nil)
            }
        }
        UserDefaults.standard.set(size.level, forKey: key)
        currentSize = size
        
    }
    
    func get() -> PianoNoteSize {
        return currentSize
    }
}

extension Notification.Name {
    static let pianoSizeInspectorSizeChanged = Notification.Name("pianoSizeInspectorSizeChanged")
}
