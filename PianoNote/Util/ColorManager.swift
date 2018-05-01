//
//  ColorManager.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 30..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

///Define Color presets here
class ColorManager {
    static let shared = ColorManager()
    
    private init() {}
    private var preset: ColorPreset = .white
    
    //background color
    //font foreground color
    //font background color
    //font highlight color
    //underline, strikethrough color
    //merge highlight color
    
    func textViewBackground() -> UIColor {
        switch preset {
        case .white: return UIColor.white
        }
    }
    
    func foreground() -> UIColor {
        switch preset {
        case .white: return UIColor.blue
        }
    }
    
    func highlightBackground() -> UIColor {
        switch preset {
        case .white: return UIColor(hex6: "229CFF")
        }
    }
    
    func underLine() -> UIColor {
        switch preset {
        case .white: return UIColor(hex6: "007AFF")
        }
    }
    
    func mergeHighlightBackground() -> UIColor {
        switch preset {
        case .white: return UIColor.orange
        }
    }
}

enum ColorPreset {
    case white
}
