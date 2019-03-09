//
//  Assistable.swift
//  AssistView
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 Piano. All rights reserved.
//

import Foundation
import CoreGraphics

/*
< PianoTextView에서 해야할 일 >
 1. assistDatas에 모든 키워드 할당하기
 1. assistDataSource = [] 할당하기
 2. canBecomeFirstResponder를 true로 오버라이드하기
 3. keyCommands에 assistableKeyCommands를 append하여 오버라이드하기
 
 */

extension ViewTag {
    static let PianoAssistTableView = "PianoAssistTableView"
}

protocol Assistable: class where Self: PianoTextView {
    var assistDataSource: [PianoAssistData] { get set }
    var assistDatas: [PianoAssistData] { get set }
}

extension Assistable {
    var assistableKeyCommands: [KeyCommand] {
        get {
            guard self.hasSubView(viewTag: ViewTag.PianoAssistTableView) else { return [] }
            return [
                KeyCommand(input: "UIKeyInputUpArrow", modifierFlags: [], action: #selector(upArrow(sender:))),
                KeyCommand(input: "UIKeyInputDownArrow", modifierFlags: [], action: #selector(downArrow(sender:))),
                KeyCommand(input: "UIKeyInputEscape", modifierFlags: [], action: #selector(escape(sender:))),
                KeyCommand(input: "\r", modifierFlags: [], action: #selector(newline(sender:)))
            ]
        }
    }
    
    func showAssistViewIfNeeded() {
        assistDataSource = []
        guard let textRange = textRangeAfterSharp(),
            let position = selectedTextRange?.end else {
            hideAssistViewIfNeeded()
            return
        }
        
        let caretRect = self.caretRect(for: position)
        let matchedText = (text as NSString).substring(with: textRange)
        
        if matchedText.isEmpty {
            //전체 키워드를 대입
            assistDataSource = assistDatas
            showAssistView(caretRect)
            return
        } else {
            for var assistData in assistDatas {
                if assistData.keyword.hangul.contains(matchedText.hangul) {
                    assistData.input = matchedText
                    assistDataSource.append(assistData)
                }
            }
            if !assistDataSource.isEmpty {
                showAssistView(caretRect)
                return
            }
        }
        hideAssistViewIfNeeded()
    }
    
    func hideAssistViewIfNeeded() {
        subView(viewTag: ViewTag.PianoAssistTableView)?.removeFromSuperview()
    }
    
    func replaceProcess() {
        
        guard let tableView = subView(viewTag: ViewTag.PianoAssistTableView) as? PianoAssistTableView,
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: selectedIndexPath) as? PianoAssistTableViewCell,
            let text = cell.titleLabel.text,
            let textRange = textRangeAfterSharp() else { return }
        
        textStorage.replaceCharacters(in: textRange, with: text)
        selectedRange.location += (text.count - textRange.length)
        hideAssistViewIfNeeded()
        
    }
}

extension Assistable {
    private func textRangeAfterSharp() -> NSRange? {
        let paraRange = (text as NSString).paragraphRange(for: selectedRange)
        let regex = "^\\s*(#)(?=)"
        if let (_, range) = text.detect(searchRange: paraRange, regex: regex),
            selectedRange.location >= range.location + 1 {
            
            return NSMakeRange(range.location + 1, selectedRange.location - (range.location + 1))
        }
        return nil
    }
    
    private func showAssistView(_ caretRect: CGRect) {
        if let assistView = createSubviewIfNeeded(viewTag: ViewTag.PianoAssistTableView) as? PianoAssistTableView {
            assistView.setup(assistable: self)
            addSubview(assistView)
            assistView.setPosition(textView: self, at: caretRect)
        }
    }
}




