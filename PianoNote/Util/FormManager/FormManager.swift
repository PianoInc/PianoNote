//
//  File.swift
//  PianoNote
//
//  Created by Kevin Kim on 2018. 2. 28..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation
import CoreGraphics

private enum BulletOperation {
    case reset
    case delete
    case add
    case none
}

public struct FormManager {
    
    private init(){}
    
    /**
     A method that operate reset & delete & add before changing textView.
     reset: reset bullet to original key before typing
     delete: delete bullet when typing enter key
     add: add bullet when typing enter key
     */
//    public static func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        
//        guard let bullet = PianoBullet(text: textView.text, selectedRange: textView.selectedRange),
//            bullet.type != .key else { return true }
//
//        let type = operationType(textView, shouldChangeTextIn: range, replacementText: text, bullet: bullet)
//        
//        switch type {
//        case .reset:
//            return resetBullet(textView, bullet: bullet)
//        case .delete:
//            return deleteBullet(textView, bullet: bullet)
//        case .add:
//            return addBullet(textView, bullet: bullet)
//        case .none:
//            return true
//        }
//        
//    }
    
    
    /**
     A method that apply attributes after changing textView.
     */
    public static func textViewDidChange(_ textView: TextView) {
        
        guard var bullet = PianoBullet(text: textView.text, selectedRange: textView.selectedRange) else {
            let paraRange = (textView.text as NSString).paragraphRange(for: textView.selectedRange)
            textView.textStorage.addAttributes([.paragraphStyle : FormAttributes.defaultParagraphStyle], range: paraRange)
            return
        }
        
        switch bullet.type {
        case .number:
            adjust(textView, bullet: &bullet)
            addAttributesToBullet(textView, bullet: bullet)
            adjustAfter(textView, bullet: &bullet)
            
        case .key:
            change(textView, bullet: bullet)
            addAttributesToBullet(textView, bullet: bullet)
            
        case .value:
            ()
        }
    }
    
}

//ShouldChange
extension FormManager {
    
    private static func resetBullet(_ textView: TextView, bullet: PianoBullet) -> Bool {
        
        switch bullet.type {
        case .number:
            //구두점을 포함해서 색상, 폰트를 리셋한다.
            var range = bullet.range
            range.length += 1 //punctuation
            textView.textStorage.addAttributes([.foregroundColor : Color.darkText, .font: Font.preferredFont(forTextStyle: .body)], range: range)
            
        case .value:
            //키로 바꿔주고 색상, 폰트를 리셋한다.
            let attrString = NSAttributedString(
                string: bullet.converted!,
                attributes: [.foregroundColor: Color.darkText,
                             .font : Font.preferredFont(forTextStyle: .body)
                ])
            textView.textStorage.replaceCharacters(in: bullet.range, with: attrString)
        default:
            ()
        }
        
        textView.textStorage.addAttributes(
            [.paragraphStyle : FormAttributes.defaultParagraphStyle],
            range: bullet.paraRange)
        
        return true
    }
    
    private static func deleteBullet(_ textView: TextView, bullet: PianoBullet) -> Bool {
        
        let range = NSMakeRange(
            bullet.paraRange.location,
            bullet.baselineIndex - bullet.paraRange.location)
        textView.textStorage.replaceCharacters(in: range, with: "")
        if bullet.paraRange.location + bullet.paraRange.length < textView.text.count {
            textView.selectedRange.location -= range.length
        }
        
        return false
    }
    
    private static func addBullet(_ textView: TextView, bullet: PianoBullet) -> Bool {
        
        let range = NSMakeRange(
            bullet.paraRange.location,
            bullet.baselineIndex - bullet.paraRange.location)
        let mutableAttrString = NSMutableAttributedString(attributedString: textView.attributedText.attributedSubstring(from: range))
        switch bullet.type {
        case .number:
            let relativeNumRange = NSMakeRange(bullet.range.location - range.location, bullet.range.length)
            guard let number = UInt(bullet.string) else { return true }
            let nextNumber = number + 1
            mutableAttrString.replaceCharacters(
                in: relativeNumRange,
                with: String(nextNumber))
            
            
        default:
            //나머지는 그대로 진행하면 됨
            ()
        }
        let enter = NSAttributedString(string: "\n")
        mutableAttrString.insert(enter, at: 0)
        textView.insertBulletString(mutableAttrString)
        return false
        
    }
    
}

extension FormManager {
    
    private static func adjustAfter(_ textView: TextView, bullet: inout PianoBullet) {
        
        while bullet.paraRange.location + bullet.paraRange.length < textView.textStorage.length {
            let range = NSMakeRange(bullet.paraRange.location + bullet.paraRange.length + 1, 0)
            guard let nextBullet = PianoBullet(text: textView.text, selectedRange: range),
                let currentNum = UInt(bullet.string),
                nextBullet.type == .number,
                !nextBullet.isOverflow, bullet.whitespaces.string == nextBullet.whitespaces.string,
                !bullet.isSequencial(next: nextBullet) else { return }
            
            let nextNum = currentNum + 1
            textView.textStorage.replaceCharacters(in: nextBullet.range, with: "\(nextNum)")
            
            bullet = nextBullet
            
            guard let adjustNextBullet = PianoBullet(text: textView.text, selectedRange: range),
                !adjustNextBullet.isOverflow else { return }
            
            let width = textView.attributedText.attributedSubstring(from: adjustNextBullet.range).size().width
            let paragraphStyle = FormAttributes.makeParagraphStyle(bullet: adjustNextBullet, whitespaceWidth: width)
            
            textView.textStorage.addAttributes(
                [.font : FormAttributes.numFont,
                 .foregroundColor : FormAttributes.effectColor],
                range: adjustNextBullet.range)
            textView.textStorage.addAttributes(
                [.foregroundColor: FormAttributes.punctuationColor],
                range: NSMakeRange(adjustNextBullet.baselineIndex - 2, 1))
            textView.textStorage.addAttributes(
                [.paragraphStyle : paragraphStyle],
                range: adjustNextBullet.paraRange)
            
            bullet = adjustNextBullet
        }
        
    }
    
    private static func adjust(_ textView: TextView, bullet: inout PianoBullet) {
        
        guard let prevBullet = bullet.prevBullet(text: textView.text),
            let prevNumber = UInt(prevBullet.string),
            prevBullet.type == .number,
            !prevBullet.isOverflow,
            bullet.whitespaces.string == prevBullet.whitespaces.string,
            !prevBullet.isSequencial(next: bullet) else { return }
        
        let numberString = "\(prevNumber + 1)"
        textView.textStorage.replaceCharacters(in: bullet.range, with: numberString)
        textView.selectedRange.location += (numberString.count - bullet.string.count)
        
        if let adjustBullet = PianoBullet(text: textView.text, selectedRange: textView.selectedRange) {
            bullet = adjustBullet
        }
        
    }
    
    private static func addAttributesToBullet(_ textView: TextView, bullet: PianoBullet) {
        
        guard !bullet.isOverflow else { return }
        
        switch bullet.type {
        case .number:
            textView.textStorage.addAttributes(
                [.font : FormAttributes.numFont,
                 .foregroundColor : FormAttributes.effectColor
                ],
                range: bullet.range)
            textView.textStorage.addAttributes(
                [.font : Font.preferredFont(forTextStyle: .body),
                 .foregroundColor : FormAttributes.punctuationColor],
                range: NSMakeRange(bullet.baselineIndex - 2, 1))
        default:
            let formatString = bullet.converted!
            let kern = FormAttributes.makeFormatKern(formatString: formatString)
            textView.textStorage.addAttributes(
                [.font : Font.preferredFont(forTextStyle: .body),
                 .foregroundColor : FormAttributes.effectColor,
                 .kern : kern],
                range: bullet.range)
            
        }
        
        let width = textView.attributedText.attributedSubstring(from: bullet.whitespaces.range).size().width
        let paragraphStyle = FormAttributes.makeParagraphStyle(bullet: bullet, whitespaceWidth: width)
        textView.textStorage.addAttributes(
            [.paragraphStyle: paragraphStyle],
            range: bullet.paraRange)
    }
    
    private static func change(_ textView: TextView, bullet: PianoBullet) {
        textView.textStorage.replaceCharacters(in: bullet.range, with: bullet.converted!)
    }
    
}

