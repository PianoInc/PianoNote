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
    
    public static var headIndent: CGFloat = 30
    public static var tailIndent: CGFloat = -20
    public static var font: Font = Font.preferredFont(forTextStyle: .body) {
        didSet {
            updateAttributes()
        }
    }
    
    public static var numFont: Font {
        return Font(name: "Avenir Next", size: FormAttributes.font.pointSize)!
    }
    public static var textColor: Color = Color(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    public static var punctuationColor: Color = Color.lightGray
    public static var effectColor: Color = Color(red: 255/255, green: 82/255, blue: 82/255, alpha: 1)
    public static var alignment: TextAlignment = TextAlignment.natural
    public static var lineSpacing: CGFloat = 8
    
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
    
    internal static func fontStyle(_ textView: TextView,by text: String) -> FontStyle {
        
        let fontStyle: FontStyle
        switch text {
        case "♩":
            fontStyle = .title3
        case "♪":
            fontStyle = .title2
        case "♫":
            fontStyle = .title1
        default:
            fontStyle = .body
        }
        
        return fontStyle
    }
    
    internal static func makeUnorderedParagraphStyle(whitespaceWidth: CGFloat, formatString: String) -> MutableParagraphStyle {
        let paragraphStyle = MutableParagraphStyle()
        
        let orderedWidth = NSAttributedString(string: "4", attributes: [
            .font : numFont]).size().width
        let punctuationMarkWidth = NSAttributedString(string: ".", attributes: [
            .font : font]).size().width
        let spaceWidth = NSAttributedString(string: " ", attributes: [
            .font : font]).size().width
        let formatStringWidth = NSAttributedString(string: formatString, attributes: [
            .font : font]).size().width
        
        let firstLineHeadIndent =
            formatStringWidth > orderedWidth + punctuationMarkWidth ?
                headIndent - (spaceWidth + formatStringWidth) :
                headIndent - (spaceWidth + (orderedWidth + punctuationMarkWidth + formatStringWidth )/2)
        
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
                               .kern: 0
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
        
        defaultAttributes = makeDefaultAttributes(keepParagraphStyle: false)
        defaultAttributesWithoutParagraphStyle = makeDefaultAttributes(keepParagraphStyle: true)
        //        circleKern = makeFormatKern(formatString: AutoListFormat.defaultFormatsLinker[0])
        //        emptyCircleKern = makeFormatKern(formatString: AutoListFormat.defaultFormatsLinker[1])
        //        starKern = makeFormatKern(formatString: AutoListFormat.defaultFormatsLinker[2])
        
    }
}

