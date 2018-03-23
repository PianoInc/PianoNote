//
//  ViewTag.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation


enum ViewTag: Int {
    case PianoButton = 1000
    case PianoSegmentControl = 1001
    case AnimatableTextsView = 1002
    
    case TempImageView = 2000
    
    var identifier: String {
        return String(describing: self)
    }
}
