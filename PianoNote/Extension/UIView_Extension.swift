//
//  UIView_Extension.swift
//  PianoNote
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation

extension View {
    
    internal func hasSubView(viewTag: String) -> Bool {
        
        return self.viewWithTag(viewTag.hashValue) != nil ? true : false
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
    
    internal func subView(viewTag: String) -> View? {
        return viewWithTag(viewTag.hashValue)
        
    }
    
    internal func createSubviewIfNeeded(viewTag: String) -> View {
        
        if let view = self.viewWithTag(viewTag.hashValue) {
            return view
        }
        
        let nib = Nib(nibName: viewTag, bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! View
        view.tag = viewTag.hashValue
        return view
        
    }
    
}
