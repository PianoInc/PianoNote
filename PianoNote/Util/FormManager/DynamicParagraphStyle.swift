//
//  DynamicParagraphStyle.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 1..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import InteractiveTextEngine_iOS

class DynamicParagraphStyle: NSMutableParagraphStyle {
    let spaceCount: Int
    let tabCount: Int
    let bulletType: PianoBullet.PianoBulletType
    let bulletString: String

    static let defaultStyle = DynamicParagraphStyle(bulletType: .value, bulletString: "", spaceCount: 0, tabCount: 0)

    private var numFont: UIFont {
        let size = PianoFontAttribute.standard().getFont().pointSize
        return UIFont(name: "Avenir Next", size: size)!
    }

    private var numberingWidth: CGFloat {
        return "4".nsString.size(withAttributes: [.font: numFont]).width
    }

    private var punctuationMarkWidth: CGFloat {
        return ".".nsString.size(withAttributes: [.font: PianoFontAttribute.standard().getFont()]).width
    }

    private var spaceWidth: CGFloat {
        return " ".nsString.size(withAttributes: [.font: PianoFontAttribute.standard().getFont()]).width
    }

    private var whiteSpaceString: String {
        return String(repeating: " ", count: spaceCount) + String(repeating: "\t", count: tabCount)
    }

    override var firstLineHeadIndent: CGFloat {
        set{}
        get {
            switch bulletType{
                case .number: return FormAttributes.headIndent - (numberingWidth + punctuationMarkWidth + spaceWidth)
                default:
                    let bulletWidth = NSAttributedString(string: bulletString,
                            attributes: [.font: PianoFontAttribute.standard().getFont()]).size().width
                    return bulletWidth > numberingWidth + punctuationMarkWidth ?
                                FormAttributes.headIndent - (spaceWidth + bulletWidth) :
                            FormAttributes.headIndent - (spaceWidth + (numberingWidth + punctuationMarkWidth + bulletWidth)/2)
            }
        }
    }

    override var headIndent: CGFloat {
        set{}
        get {

            let whitespaceWidth = whiteSpaceString.nsString.size(withAttributes: [.font: PianoFontAttribute.standard().getFont()]).width
            
            return whitespaceWidth + firstLineHeadIndent
        }
    }


    init(bulletType: PianoBullet.PianoBulletType, bulletString: String, spaceCount: Int, tabCount: Int) {
        self.bulletType = bulletType
        self.bulletString = bulletString
        self.spaceCount = spaceCount
        self.tabCount = tabCount

        super.init()

        self.lineSpacing = FormAttributes.lineSpacing
        self.tailIndent = FormAttributes.tailIndent
    }

    convenience init(bullet: PianoBullet, spaceCount: Int, tabCount: Int) {
        let bulletType = bullet.type
        let bulletString = bullet.type == .key ? bullet.converted! : bullet.string

        self.init(bulletType: bulletType, bulletString: bulletString, spaceCount: spaceCount, tabCount: tabCount)
    }

    required init?(coder aDecoder: NSCoder) {
        self.bulletType = .value
        self.bulletString = ""
        self.spaceCount = 0
        self.tabCount = 0

        super.init(coder: aDecoder)

        self.lineSpacing = FormAttributes.lineSpacing
        self.tailIndent = FormAttributes.tailIndent
    }
}
