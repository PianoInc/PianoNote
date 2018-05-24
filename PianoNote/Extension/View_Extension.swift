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
    
    internal func hasSubView(identifier: String) -> Bool {
        
        return self.viewWithTag(identifier.hashValue) != nil ? true : false
    }
    
    internal func subView(identifier: String) -> View? {
        return viewWithTag(identifier.hashValue)
        
    }
    
    internal func createSubviewIfNeeded(identifier: String) -> View {
        
        if let view = self.viewWithTag(identifier.hashValue) {
            return view
        }
        
        let nib = Nib(nibName: identifier, bundle: nil)
        for object in nib.instantiate(withOwner: nil, options: nil) {
            if let view = object as? View {
                view.tag = identifier.hashValue
                return view
            }
        }
        
        fatalError("can't create view with this ViewTag")
    }
    
}
