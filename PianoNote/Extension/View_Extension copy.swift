//
//  UIView_Extension.swift
//  PianoNote
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation
import CoreGraphics

extension View {
    
    internal func hasSubView(viewTag: String) -> Bool {
        
        return self.viewWithTag(viewTag.hashValue) != nil ? true : false
    }
    
    internal func subView(viewTag: String) -> View? {
        return viewWithTag(viewTag.hashValue)
        
    }
    
    internal func createSubviewIfNeeded(viewTag: String) -> View {
        
        if let view = self.viewWithTag(viewTag.hashValue) {
            return view
        }
        
        let nib = Nib(nibName: viewTag, bundle: nil)
        for object in nib.instantiate(withOwner: nil, options: nil) {
            if let view = object as? View {
                view.tag = viewTag.hashValue
                return view
            }
        }
        
        fatalError("can't create view with this ViewTag")
    }
    
}
