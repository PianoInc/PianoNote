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
    case PianoView = 1002
    case PianoControl = 1003
    case PianoTextView = 1004
    case PianoCoverView = 1005
    
    case PianoAssistTableView = 2000
    
    var identifier: String {
        return String(describing: self)
    }
}

extension View {
    
    internal func hasSubView(tag: ViewTag) -> Bool {
        return self.viewWithTag(tag.rawValue) != nil ? true : false
    }
    
//    internal func subView(tag: ViewTag) -> View {
//
//        if let view = self.viewWithTag(tag.rawValue) {
//            return view
//        }
//        let nib = Nib(nibName: tag.identifier, bundle: nil)
//        let view = nib.instantiate(withOwner: nil, options: nil).first as! View
//        view.tag = tag.rawValue
//
//        return view
//
//    }
    
    internal func subView(tag: ViewTag) -> View? {
        return viewWithTag(tag.rawValue)
        
    }
    
    internal func createSubviewIfNeeded(tag: ViewTag) -> View {
        
        if let view = self.viewWithTag(tag.rawValue) {
            return view
        }
        
        let nib = Nib(nibName: tag.identifier, bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! View
        view.tag = tag.rawValue
        return view
        
    }

}
