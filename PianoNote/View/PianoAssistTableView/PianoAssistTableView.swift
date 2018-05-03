//
//  PianoAssistTableView.swift
//  PianoNote
//
//  Created by Kevin Kim on 30/04/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class PianoAssistTableView: UITableView {

    let regex = "^\\s*(#)(?=)"
    
    
//    func showIfNeeded(textView: UITextView, at location: CGPoint) {
//        
//        guard let text = textView.text else { return }
//        let selectedRange = textView.selectedRange
//        
//        let paraRange = (text as NSString).paragraphRange(for: selectedRange)
//        if let (_, range) = text.detect(searchRange: paraRange, regex: regex) {
//            if selectedRange.location >= range.location + 1 {
//                let textRange = NSMakeRange(range.location + 1,
//                                            selectedRange.location - (range.location + 1))
//                let matchedText = (text as NSString).substring(with: textRange)
//                show(matchedText)
//                return
//            }
//        }
//        hide()
//        
//    }
    
    
    //TODO: 히든 상태라면 히든 풀기, text가 빈 문자열이면 모든 키워드 보여주고, 키워드 안에 text가 포함되면 해당 키워드들을 보여주기, 포함되지 않는다면 히든시키기
//    func show(_ text: String) {
//
//        matchedKeywords = []
//
//        if self.isHidden {
//            isHidden = false
//        }
//
//        //text가 빈 문자열이면 모든 키워드 보여주기
//        if text.isEmpty {
//            matchedKeywords = PianoCard.keywords
//            self.frame.size.height = CGFloat(40 * matchedKeywords.count)
//            reloadData()
//            return
//        }
//
//        for pianoKeyword in PianoCard.keywords {
//            if pianoKeyword.keyword.contains(text) {
//                //TODO: 일치하는 글자에 형광색 표시를 하며 일치하는 키워드를 보여줘야함
//                matchedKeywords.append(pianoKeyword)
//            }
//        }
//
//        if matchedKeywords.isEmpty {
//            hide()
//            return
//        }
//
//        self.frame.size.height = CGFloat(40 * matchedKeywords.count)
//        reloadData()
//
//    }
//
//    func hide() {
//        matchedKeywords = []
//        isHidden = true
//    }

}
