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
        return font.pointSize + 13
    }
    public static var tailIndent: CGFloat = -20
    public static var font: Font = Font.preferredFont(forTextStyle: .body) {
        didSet {
            updateAttributes()
        }
    }
    
    public static var numFont: Font {
        return Font(name: "Avenir Next", size: FormAttributes.font.pointSize)!
    }
    public static var textColor: Color = Color.black
    public static var punctuationColor: Color = Color.lightGray
    public static var effectColor: Color = Color.point
    public static var alignment: TextAlignment = TextAlignment.natural
    public static var lineSpacing: CGFloat = 10
    
    static var defaultParagraphStyle: MutableParagraphStyle = makeDefaultParaStyle()
    static var defaultAttributes: [NSAttributedStringKey : Any] = makeDefaultAttributes(keepParagraphStyle: false)
    static var defaultAttributesWithoutParagraphStyle: [NSAttributedStringKey : Any] = makeDefaultAttributes(keepParagraphStyle: true)
    
    internal static func makeParagraphStyle(bullet: PianoBullet, whitespaceWidth: CGFloat) -> MutableParagraphStyle {
        
        let numberingWidth = NSAttributedString(
            string: "4",
            attributes: [.font : numFont])
            .size()
            .width
        let punctuationMarkWidth = NSAttributedString(
            string: ".",
            attributes: [.font : font])
            .size()
            .width
        let spaceWidth = NSAttributedString(
            string: " ",
            attributes: [.font : font])
            .size()
            .width
        
        let firstLineHeadIndent: CGFloat
        if bullet.type != .number {
            let bulletWidth = NSAttributedString(string: bullet.converted!, attributes: [
                .font : font]).size().width
            firstLineHeadIndent =
                bulletWidth > numberingWidth + punctuationMarkWidth ?
                    headIndent - (spaceWidth + bulletWidth) :
                headIndent - (spaceWidth + (numberingWidth + punctuationMarkWidth + bulletWidth )/2)
        } else {
            firstLineHeadIndent = headIndent -
                (numberingWidth + punctuationMarkWidth + spaceWidth)
        }
        let paragraphStyle = MutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
        paragraphStyle.headIndent = headIndent + whitespaceWidth
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
        var paragraphStyle = [ .foregroundColor: textColor,
                               .underlineStyle: 0,
                               .strikethroughStyle: 0,
                               .kern: 0,
                               .font: Font.preferredFont(forTextStyle: .body)
            ] as [NSAttributedStringKey : Any]
        if !keepParagraphStyle {
            paragraphStyle[.paragraphStyle] = defaultParagraphStyle
        }
        return paragraphStyle
    }
    
    internal static func makeFormatKern(formatString: String) -> CGFloat {
        
        let num = NSAttributedString(string: "4", attributes: [
            .font : numFont]).size()
        let dot = NSAttributedString(string: ".", attributes: [
            .font : font]).size()
        let form = NSAttributedString(string: formatString, attributes: [
            .font : font]).size()
        return form.width > num.width + dot.width ? 0 : (num.width + dot.width - form.width)/2
    }
    
    internal static func updateAttributes() {
        
        defaultParagraphStyle = makeDefaultParaStyle()
        defaultAttributes = makeDefaultAttributes(keepParagraphStyle: false)
        defaultAttributesWithoutParagraphStyle = makeDefaultAttributes(keepParagraphStyle: true)
        
    }
}
