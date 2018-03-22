//
//  DRBinder.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRBinder<T>: NSObject {
    
    typealias Observer = (T) -> ()
    var observer: Observer?
    var value: T {
        didSet {observer?(value)}
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    /**
     Value값의 변화를 감지하고 통지한다.
     - parameter observer : 변화된 Value값 통지.
     */
    func subscribe(_ observer: Observer?) {
        self.observer = observer
    }
    
}

