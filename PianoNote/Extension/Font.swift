//
//  Font.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/// UIFontTextStyle의 정보를 가지고 있는 textStyle.
enum DRTextStyle: String {
    /// Regular두께 28포인트
    case title1 = "UICTFontTextStyleTitle1"
    /// Regular두께 22포인트
    case title2 = "UICTFontTextStyleTitle2"
    /// Regular두께 20포인트
    case title3 = "UICTFontTextStyleTitle3"
    /// Semi-Bold두께 17포인트
    case headline = "UICTFontTextStyleHeadline"
    /// Regular두께 17포인트
    case body = "UICTFontTextStyleBody"
    /// Regular두께 16포인트
    case callout = "UICTFontTextStyleCallout"
    /// Regular두께 15포인트
    case subhead = "UICTFontTextStyleSubhead"
    /// Regular두께 13포인트
    case footnote = "UICTFontTextStyleFootnote"
    /// Regular두께 12포인트
    case caption1 = "UICTFontTextStyleCaption1"
    /// Regular두께 11포인트
    case caption2 = "UICTFontTextStyleCaption2"
}

extension UIFont {
    
    /**
     해당 style의 preferredFont를 반환한다.
     - note: [UIFontTextStyle](https://developer.apple.com/documentation/uikit/uifonttextstyle)
     - parameter font: 적용하려는 DRTextStyle.
     */
    static func preferred(font: DRTextStyle) -> UIFont {
        return UIFont.preferredFont(forTextStyle: UIFontTextStyle(font.rawValue))
    }
    
}

