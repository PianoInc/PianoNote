//
//  String.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 23..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension String {
    
    /// 해당 id를 가지는 localized string을 반환한다.
    var locale: String {
        return NSLocalizedString(self, comment: self)
    }
    
}

