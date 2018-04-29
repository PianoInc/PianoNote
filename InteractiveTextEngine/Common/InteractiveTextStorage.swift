//
//  InteractiveTextStorage.swift
//  InteractiveTextEngine
//
//  Created by 김범수 on 2018. 3. 23..
//

//import UIKit
import Foundation

class InteractiveTextStorage: NSTextStorage {

    weak var textView: InteractiveTextView?
    
    private let backingStore = NSMutableAttributedString()
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        
        attachmentChanged(deletedRange: range)
        
        beginEditing()
        backingStore.replaceCharacters(in: range, with:str)
        edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.count - range.length)
        
        endEditing()
        
    }
    
    override func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        
        attachmentChanged(deletedRange: range, newAttString: attrString)
        
        //length가 있다는 건 영역이 잡혀있다는 말
        beginEditing()
        
        let cursorLocation = range.length > 0 ? range.location + range.length : range.location
        var bullet = PianoBullet(text: string, selectedRange: NSMakeRange(cursorLocation, 0))
        var range = range
        
        //1. 기존 문단 서식 지워주는 로직
        if shouldReset(bullet: bullet, range: range, attrString: attrString) {
            resetBullet(range: &range, bullet: bullet)
        }
        
        //2. 개행일 경우 newLineOperation 체크하고 해당 로직 실행
        if enterNewline(attrString) {
            
            if shouldAddBullet(bullet: bullet, range: range, attrString: attrString) {
                addBullet(range: &range, bullet: bullet)
                endEditing()
                return
            } else if shouldDeleteBullet(bullet: bullet, range: range, attrString: attrString) {
                deleteBullet(range: &range, bullet: bullet)
                endEditing()
                return
            }
            

            if let card = PianoCard(
                text: string,
                selectedRange: NSMakeRange(cursorLocation, 0)) {
                
                //카드가 있다면 붙여주기
                let attachment = card.attachment()
                //개행을 추가해 붙이기
                let newLine = "\n"
                
                //붙이기
//                backingStore.replaceCharacters(in: <#T##NSRange#>, with: <#T##NSAttributedString#>)
                
                
                endEditing()
                return
            }
            
            //create card logic
            //            if let card = PianoCard(bullet 생성자처럼 값 대입) {
            //                attachCard(...)
            //                endEditing()
            //            }
            
            
        }
        
        //패러그랲 붙여주고, 그 패러그랲 서식검사하고 이 순서로 가기
        let mutableAttrString = NSMutableAttributedString(string: attrString.string, attributes: FormAttributes.defaultAttributes)
        var paraRange = (mutableAttrString.string as NSString).paragraphRange(for: NSMakeRange(0, 0))
        
        repeat {
            let paraAttrString = mutableAttrString.attributedSubstring(from: paraRange)
            backingStore.replaceCharacters(in: range, with: paraAttrString)
            edited([.editedCharacters], range: range, changeInLength: paraAttrString.length - range.length)
            
            //서식입혀주기
            range.length = 0
            bullet = PianoBullet(text: string, selectedRange: range)
            if let uBullet = bullet {
                switch uBullet.type {
                case .number:
                    adjust(range: &range, bullet: &bullet)
                    adjustAfter(bullet: &bullet)
                case .key:
                    replace(bullet: uBullet)
                case .value:
                    ()
                }
                addAttributesTo(bullet: &bullet)
                
            } else {
                let paraRange = (string as NSString).paragraphRange(for: range)
                backingStore.addAttributes([.paragraphStyle : FormAttributes.defaultParagraphStyle], range: paraRange)
                edited([.editedAttributes], range: paraRange, changeInLength: 0)
            }
            range.location += paraAttrString.length
            
            paraRange = (mutableAttrString.string as NSString)
                .paragraphRange(for: NSMakeRange(paraRange.location + paraRange.length, 0))
            
        } while paraRange.location + paraRange.length < mutableAttrString.length
        
        endEditing()
    }
    
    override func addAttribute(_ name: NSAttributedStringKey, value: Any, range: NSRange) {
        
        if name == .attachment, let attachment = value as? InteractiveTextAttachment {
            textView?.add(attachment)
            
        }
        
        beginEditing()
        backingStore.addAttribute(name, value: value, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override func addAttributes(_ attrs: [NSAttributedStringKey : Any] = [:], range: NSRange) {
        
        if let attachment = attrs[.attachment] as? InteractiveTextAttachment {
            textView?.add(attachment)
            attachmentChanged(deletedRange: range)
        }
        
        beginEditing()
        backingStore.addAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    override func append(_ attrString: NSAttributedString) {
        
        attachmentChanged(newAttString: attrString)
        
        beginEditing()
        let index = backingStore.length
        backingStore.append(attrString)
        edited([.editedAttributes,.editedCharacters], range: NSMakeRange(index, 0), changeInLength: attrString.length)
        endEditing()
    }
    
    override func insert(_ attrString: NSAttributedString, at loc: Int) {
        
        attachmentChanged(newAttString: attrString)
        
        beginEditing()
        backingStore.insert(attrString, at: loc)
        edited([.editedAttributes,.editedCharacters], range: NSMakeRange(loc, 0), changeInLength: attrString.length)
        endEditing()
    }
    
    override func deleteCharacters(in range: NSRange) {
        
        attachmentChanged(deletedRange: range)
        
        beginEditing()
        backingStore.deleteCharacters(in: range)
        edited([.editedAttributes, .editedCharacters], range: range, changeInLength: -range.length)
        endEditing()
    }
    
    override func removeAttribute(_ name: NSAttributedStringKey, range: NSRange) {
        
        if name == .attachment {attachmentChanged(deletedRange: range)}
        
        beginEditing()
        backingStore.removeAttribute(name, range: range)
        edited([.editedAttributes], range: range, changeInLength: 0)
        endEditing()
    }
    
    
    
    override func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        
        if let attachment = attrs?[.attachment] as? InteractiveTextAttachment {
            textView?.add(attachment)
        }
        
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    private func attachmentChanged(deletedRange: NSRange? = nil, newAttString: NSAttributedString? = nil) {
        if let deletedRange = deletedRange {
            enumerateAttribute(.attachment, in: deletedRange, options: .longestEffectiveRangeNotRequired) { (value, _, _) in
                guard let attachment = value as? InteractiveTextAttachment else {return}
//                print("delete \(attachment.uniqueID)")
                self.textView?.remove(attachmentID: attachment.uniqueID)
            }
        }

        if let newAttString = newAttString {
            newAttString.enumerateAttribute(.attachment, in: NSMakeRange(0, newAttString.length)
            , options: .longestEffectiveRangeNotRequired) { (value, _, _) in
                guard let attachment = value as? InteractiveTextAttachment else {return}
//                print("add \(attachment.uniqueID)")
                self.textView?.add(attachment)
            }
        }
    }
}

extension InteractiveTextStorage {
    
    private func shouldReset(bullet: PianoBullet?, range: NSRange, attrString: NSAttributedString) -> Bool {
        
        guard let uBullet = bullet,
            uBullet.type != .key else {
                return false
        }
        
        let string = self.string as NSString
        
        //이전문단으로 가는데 이전 문단에 문자열이 있을 경우
        if ((range.location < uBullet.paraRange.location
            && string.substring(with: string.paragraphRange(for: range))
                .trimmingCharacters(in: .whitespacesAndNewlines).count != 0)) {
            return true
        }
        
        //range.location이 bulletAndSpace의 왼쪽보다 크고, 오른쪽보다 작은 위치에 있다면 무조건 리셋
        if range.location > uBullet.range.location && range.location < uBullet.baselineIndex {
            return true
        }
        
        //whitespace범위에 whitespaceAndNewline이 아닌 글자를 입력한 경우 리셋
        if range.location >= uBullet.paraRange.location && range.location <= uBullet.range.location && attrString.string.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
            return true
        }
        
        
        return false
    }
    
    private func shouldDeleteBullet(bullet: PianoBullet?, range: NSRange, attrString: NSAttributedString) -> Bool {
        
        guard let uBullet = bullet,
            uBullet.type != .key,
            range.location + range.length
                == uBullet.baselineIndex else { return false }
        return true
        
    }
    
    private func shouldAddBullet(bullet: PianoBullet?, range: NSRange, attrString: NSAttributedString) -> Bool {
        
        guard let uBullet = bullet,
            uBullet.type != .key,
            range.location + range.length
                > uBullet.baselineIndex else { return false }
        
        return true
    }
    
    private func resetBullet(range: inout NSRange, bullet: PianoBullet?) {
        
        guard let uBullet = bullet else { return }
        
        switch uBullet.type {
        case .number:
            //구두점을 포함해서 색상, 폰트를 리셋한다.
            var resetRange = uBullet.range
            resetRange.length += 1 //punctuation
            backingStore.addAttributes([.foregroundColor : Color.darkText, .font: Font.preferredFont(forTextStyle: .body)], range: resetRange)
            edited([.editedAttributes], range: resetRange, changeInLength: 0)
            
        case .value:
            //키로 바꿔주고 색상, 폰트를 리셋한다.
            let attrString = NSAttributedString(
                string: uBullet.converted!,
                attributes: [.foregroundColor: Color.darkText,
                             .font : Font.preferredFont(forTextStyle: .body)
                ])
            
            backingStore.replaceCharacters(in: uBullet.range, with: attrString)
            edited([.editedCharacters], range: uBullet.range, changeInLength: attrString.length - uBullet.range.length)
            range.location += (attrString.length - uBullet.range.length)
            
            DispatchQueue.main.async { [weak self] in
                self?.textView?.selectedRange.location += (attrString.length - uBullet.range.length)
            }
            
            
        default:
            ()
        }
        
        backingStore.addAttributes(
            [.paragraphStyle : FormAttributes.defaultParagraphStyle],
            range: uBullet.paraRange)
        edited([.editedAttributes], range: uBullet.paraRange, changeInLength: 0)
        
    }
    
    private func deleteBullet(range: inout NSRange, bullet: PianoBullet?) {
        
        guard let uBullet = bullet else { return }
        
        let deleteRange = NSMakeRange(
            uBullet.paraRange.location,
            uBullet.baselineIndex - uBullet.paraRange.location)
        
        backingStore.addAttributes([.paragraphStyle : FormAttributes.defaultParagraphStyle], range: uBullet.paraRange)
        
        backingStore.replaceCharacters(in: deleteRange, with: "")
        
        edited(
            [.editedCharacters, .editedAttributes],
            range: deleteRange,
            changeInLength: -deleteRange.length)
        range.location += (-deleteRange.length)
        
        if uBullet.paraRange.location + uBullet.paraRange.length < string.count {
            DispatchQueue.main.async { [weak self] in
                self?.textView?.selectedRange.location -= (deleteRange.length + 1)
                
            }
            
        }
    }
    
    private func addBullet(range: inout NSRange, bullet: PianoBullet?) {
        
        guard let uBullet = bullet else { return }
        
        let addRange = NSMakeRange(
            uBullet.paraRange.location,
            uBullet.baselineIndex - uBullet.paraRange.location)
        let mutableAttrString = NSMutableAttributedString(attributedString: backingStore.attributedSubstring(from: addRange))
        switch uBullet.type {
        case .number:
            let relativeNumRange = NSMakeRange(uBullet.range.location - addRange.location, uBullet.range.length)
            guard let number = UInt(uBullet.string) else { return }
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
        backingStore.replaceCharacters(in: range, with: mutableAttrString)
        edited([.editedCharacters], range: range, changeInLength: mutableAttrString.length - range.length)
        range.location += (mutableAttrString.length - range.length)
        
        
        DispatchQueue.main.async { [weak self] in
            self?.textView?.selectedRange.location += (mutableAttrString.length - 1)
        }
        
    }
    
    private func enterNewline(_ attrString: NSAttributedString) -> Bool {
        return attrString.string == "\n"
    }
    
    private func adjust(range: inout NSRange, bullet: inout PianoBullet?) {
        
        guard let uBullet = bullet,
            let prevBullet = uBullet.prevBullet(text: string),
            let prevNumber = UInt(prevBullet.string),
            prevBullet.type == .number,
            !prevBullet.isOverflow,
            uBullet.whitespaces.string == prevBullet.whitespaces.string,
            !prevBullet.isSequencial(next: uBullet) else { return }
        
        let numberString = "\(prevNumber + 1)"
        backingStore.replaceCharacters(in: uBullet.range, with: numberString)
        edited([.editedCharacters], range: uBullet.range, changeInLength: numberString.count - uBullet.range.length)
        
        let count = uBullet.range.length
        DispatchQueue.main.async { [weak self] in
            self?.textView?.selectedRange.location += (numberString.count - count)
        }
        
        
        
        guard range.location > 0 else { return }
        if let adjustBullet = PianoBullet(text: string, selectedRange: NSMakeRange(range.location, 0)) {
            bullet = adjustBullet
        }
        
    }
    
    private func addAttributesTo(bullet: inout PianoBullet?) {
        
        guard let bullet = bullet, !bullet.isOverflow else { return }
        
        switch bullet.type {
        case .number:
            backingStore.addAttributes(
                [.font : FormAttributes.numFont,
                 .foregroundColor : FormAttributes.effectColor
                ],
                range: bullet.range)
            edited(
                [.editedAttributes],
                range: bullet.range,
                changeInLength: 0)
            
            backingStore.addAttributes(
                [.font : Font.preferredFont(forTextStyle: .body),
                 .foregroundColor : FormAttributes.punctuationColor],
                range: NSMakeRange(bullet.baselineIndex - 2, 1))
            edited(
                [.editedAttributes],
                range: NSMakeRange(bullet.baselineIndex - 2, 1),
                changeInLength: 0)
            
        case .key:
            let formatString = bullet.converted!
            let kern = FormAttributes.makeFormatKern(formatString: formatString)
            backingStore.addAttributes(
                [.font : Font.preferredFont(forTextStyle: .body),
                 .foregroundColor : FormAttributes.effectColor,
                 .kern : kern],
                range: bullet.range)
            
            edited(
                [.editedAttributes],
                range: bullet.range,
                changeInLength: 0)
            
        case .value:
            let formatString = bullet.string
            let kern = FormAttributes.makeFormatKern(formatString: formatString)
            backingStore.addAttributes(
                [.font : Font.preferredFont(forTextStyle: .body),
                 .foregroundColor : FormAttributes.effectColor,
                 .kern : kern],
                range: bullet.range)
            
            edited(
                [.editedAttributes],
                range: bullet.range,
                changeInLength: 0)
            
        }
        
        let width = backingStore.attributedSubstring(from: NSMakeRange(bullet.paraRange.location, bullet.baselineIndex - bullet.paraRange.location)).size().width
        let paragraphStyle = FormAttributes.makeParagraphStyle(bullet: bullet, whitespaceWidth: width)
        
        backingStore.addAttributes(
            [.paragraphStyle: paragraphStyle],
            range: bullet.paraRange)
        edited(
            [.editedAttributes],
            range: bullet.range,
            changeInLength: 0)
    }
    
    private func adjustAfter(bullet: inout PianoBullet?) {
        
        guard var uBullet = bullet else {
            return
        }
        
        while uBullet.paraRange.location + uBullet.paraRange.length < string.count {
            let range = NSMakeRange(uBullet.paraRange.location + uBullet.paraRange.length + 1, 0)
            guard let nextBullet = PianoBullet(text: string, selectedRange: range),
                let currentNum = UInt(uBullet.string),
                nextBullet.type == .number,
                !nextBullet.isOverflow, uBullet.whitespaces.string == nextBullet.whitespaces.string,
                !uBullet.isSequencial(next: nextBullet) else { return }
            
            let nextNum = currentNum + 1
            backingStore.replaceCharacters(in: nextBullet.range, with: "\(nextNum)")
            edited([.editedCharacters], range: nextBullet.range, changeInLength: "\(nextNum)".count - nextBullet.range.length)
            
            bullet = nextBullet
            uBullet = nextBullet
            
            guard let adjustNextBullet = PianoBullet(text: string, selectedRange: range),
                !adjustNextBullet.isOverflow else { return }
            
            let width = backingStore.attributedSubstring(from: adjustNextBullet.range).size().width
            let paragraphStyle = FormAttributes.makeParagraphStyle(bullet: adjustNextBullet, whitespaceWidth: width)
            
            backingStore.addAttributes(
                [.font : FormAttributes.numFont,
                 .foregroundColor : FormAttributes.effectColor],
                range: adjustNextBullet.range)
            edited(
                [.editedAttributes],
                range: adjustNextBullet.range,
                changeInLength: 0)
            
            
            backingStore.addAttributes(
                [.foregroundColor: FormAttributes.punctuationColor],
                range: NSMakeRange(adjustNextBullet.baselineIndex - 2, 1))
            edited(
                [.editedAttributes],
                range: NSMakeRange(adjustNextBullet.baselineIndex - 2, 1),
                changeInLength: 0)
            
            backingStore.addAttributes(
                [.paragraphStyle : paragraphStyle],
                range: adjustNextBullet.paraRange)
            edited(
                [.editedAttributes],
                range: adjustNextBullet.paraRange,
                changeInLength: 0)
            
            uBullet = adjustNextBullet
            bullet = adjustNextBullet
        }
        
    }
    
    private func replace(bullet: PianoBullet) {
        
        guard let convertedString = bullet.converted else { return }
        backingStore.replaceCharacters(in: bullet.range, with: convertedString)
        edited([.editedCharacters], range: bullet.range, changeInLength: convertedString.count - bullet.range.length)
        
        DispatchQueue.main.async { [weak self] in
            self?.textView?.selectedRange.location += (convertedString.count - bullet.range.length)
        }
        
    }
    
    
}
