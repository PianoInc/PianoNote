//
//  Font.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UIFont {
    
    /**
     해당 Size를 가지는 preferred system font를 반환한다.
     - note: [UIFontTextStyle](https://developer.apple.com/documentation/uikit/uifonttextstyle)
     - parameter size: 적용하려는 size.
     */
    static func preferred(font size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: .body)
        return UIFont.systemFont(ofSize: size * (font.fontDescriptor.pointSize / 17), weight: weight)
    }
    
}

