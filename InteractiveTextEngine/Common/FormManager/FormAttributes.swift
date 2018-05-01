//
//  FormAttributes.swift
//  PianoNote
//
//  Created by Kevin Kim on 2018. 3. 5..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation
import CoreGraphics

public class FormAttributes {
    
    public static var headIndent: CGFloat {
        return Font.preferredFont(forTextStyle: .body).pointSize + 13
    }
    public static var tailIndent: CGFloat = -20
    
    public static var numFont: Font = Font(name: "Avenir Next", size: Font.preferredFont(forTextStyle: .body).pointSize)!

    public static var defaultColor: Color = Color.black
    public static var punctuationColor: Color = Color.lightGray
    public static var effectColor: Color = Color.point
    public static var alignment: TextAlignment = TextAlignment.natural
    public static var lineSpacing: CGFloat = 5

    public static var defaultFont: Font = Font.preferredFont(forTextStyle: .body)
    
    static var defaultParagraphStyle: MutableParagraphStyle = makeDefaultParaStyle()
    public static var defaultAttributes: [NSAttributedStringKey : Any] = makeDefaultAttributes(keepParagraphStyle: false)
    public static var defaultTypingAttributes: [String : Any] = makeDefaultTypingAttributes()
    static var defaultAttributesWithoutParagraphStyle: [NSAttributedStringKey : Any] = makeDefaultAttributes(keepParagraphStyle: true)
    
    public static var customMakeParagraphStyle: ((PianoBullet, Int, Int) -> MutableParagraphStyle)? = nil
    
    internal static func makeParagraphStyle(bullet: PianoBullet, whitespaceWidth: CGFloat) -> MutableParagraphStyle {
        
        let numberingWidth = NSAttributedString(
            string: "4",
            attributes: [.font : numFont])
            .size()
            .width
        let punctuationMarkWidth = NSAttributedString(
            string: ".",
            attributes: [.font : Font.preferredFont(forTextStyle: .body)])
            .size()
            .width
        let spaceWidth = NSAttributedString(
            string: " ",
            attributes: [.font : Font.preferredFont(forTextStyle: .body)])
            .size()
            .width
        
        let firstLineHeadIndent: CGFloat
        switch bullet.type {
        case .number:
            firstLineHeadIndent = headIndent -
                (numberingWidth + punctuationMarkWidth + spaceWidth)
            
        case .key:
            let bulletWidth = NSAttributedString(string: bullet.converted!, attributes: [
                .font : Font.preferredFont(forTextStyle: .body)]).size().width
            firstLineHeadIndent =
                bulletWidth > numberingWidth + punctuationMarkWidth ?
                    headIndent - (spaceWidth + bulletWidth) :
                headIndent - (spaceWidth + (numberingWidth + punctuationMarkWidth + bulletWidth )/2)
            
        case .value:
            let bulletWidth = NSAttributedString(string: bullet.string, attributes: [
                .font : Font.preferredFont(forTextStyle: .body)]).size().width
            firstLineHeadIndent =
                bulletWidth > numberingWidth + punctuationMarkWidth ?
                    headIndent - (spaceWidth + bulletWidth) :
                headIndent - (spaceWidth + (numberingWidth + punctuationMarkWidth + bulletWidth )/2)

        }
        
        let paragraphStyle = MutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
        paragraphStyle.headIndent = whitespaceWidth + firstLineHeadIndent
        paragraphStyle.tailIndent = tailIndent
        paragraphStyle.lineSpacing = lineSpacing
        return paragraphStyle
        
    }
    
    internal static func makeDefaultParaStyle() ->  MutableParagraphStyle {
        let paragraphStyle = MutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = headIndent
        paragraphStyle.headIndent = headIndent
        paragraphStyle.tailIndent = tailIndent
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        return paragraphStyle
    }
    
    internal static func makeDefaultAttributes(keepParagraphStyle: Bool) -> [NSAttributedStringKey : Any] {
        var paragraphStyle = [ .foregroundColor: defaultColor,
                               .underlineStyle: 0,
                               .strikethroughStyle: 0,
                               .kern: 0,
                               .font: defaultFont,
                               .backgroundColor: Color.clear,
                               .baselineOffset: -lineSpacing
            ] as [NSAttributedStringKey : Any]
        if !keepParagraphStyle {
            paragraphStyle[.paragraphStyle] = defaultParagraphStyle
        }
        return paragraphStyle
    }
    
    internal static func makeDefaultTypingAttributes() -> [String : Any] {
        
        return [ NSAttributedStringKey.foregroundColor.rawValue : defaultColor,
                 NSAttributedStringKey.underlineStyle.rawValue : 0,
                 NSAttributedStringKey.strikethroughStyle.rawValue : 0,
                 NSAttributedStringKey.kern.rawValue : 0,
                 NSAttributedStringKey.font.rawValue : defaultFont,
                 NSAttributedStringKey.baselineOffset.rawValue: -lineSpacing,
                 NSAttributedStringKey.paragraphStyle.rawValue: defaultParagraphStyle
        ]
        
    }
    
    internal static func makeFormatKern(formatString: String) -> CGFloat {
        
        let num = NSAttributedString(string: "4", attributes: [
            .font : numFont]).size()
        let dot = NSAttributedString(string: ".", attributes: [
            .font : Font.preferredFont(forTextStyle: .body)]).size()
        let form = NSAttributedString(string: formatString, attributes: [
            .font : Font.preferredFont(forTextStyle: .body)]).size()
        return form.width > num.width + dot.width ? 0 : (num.width + dot.width - form.width)/2
    }
    
    internal static func updateAttributes() {
        
        defaultParagraphStyle = makeDefaultParaStyle()
        defaultAttributes = makeDefaultAttributes(keepParagraphStyle: false)
        defaultAttributesWithoutParagraphStyle = makeDefaultAttributes(keepParagraphStyle: true)
        
    }
}

