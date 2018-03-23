//
//  Temp.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation

extension View {
    
    internal func subView(tag: ViewTag) -> View {
        
        if let view = self.viewWithTag(tag.rawValue) {
            return view
        }
        let nib = Nib(nibName: tag.identifier, bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! View
        view.tag = tag.rawValue
        self.addSubview(view)
        return view
        
    }
}
