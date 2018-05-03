//
//  UITextViewDelegate.swift
//  PianoNote
//
//  Created by Kevin Kim on 29/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

extension NoteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //네비게이션바에 타이핑용 아이템들 세팅하기
        setNavigationItemsForTyping()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //내비게이션바에 디폴트 아이템들 세팅하기
        setNavigationItemsForDefault()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let textView = scrollView as? PianoTextView,
            !textView.isEditable else { return }
        textView.attachControl()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        guard let textView = scrollView as? PianoTextView,
            !textView.isEditable,
            !decelerate else { return }
        textView.attachControl()
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        guard let textView = scrollView as? PianoTextView,
            !textView.isEditable else { return }
        textView.detachControl()
        
    }
    
  
    
    func textViewDidChange(_ textView: UITextView) {
        
        showAssistViewIfNeeded(textView, at: CGPoint.zero)

    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        hideAssistView()
    }
    

    private func showAssistViewIfNeeded(_ textView: UITextView, at: CGPoint) {
        
        guard let text = textView.text else { return }
        let selectedRange = textView.selectedRange
        matchedKeywords = []
        
        let paraRange = (text as NSString).paragraphRange(for: selectedRange)
        let regex = "^\\s*(#)(?=)"
        if let (_, range) = text.detect(searchRange: paraRange, regex: regex) {
            if selectedRange.location >= range.location + 1 {
                let textRange = NSMakeRange(range.location + 1, selectedRange.location - (range.location + 1))
                let matchedText = (text as NSString).substring(with: textRange)
                
                if matchedText.isEmpty {
                    //전체 키워드를 대입
                    matchedKeywords = PianoCard.keywords
                    showAssistView()
                    return
                    
                } else {
                    for pianoKeyword in PianoCard.keywords {
                        if pianoKeyword.keyword.contains(matchedText) {
                            //TODO: 일치하는 글자에 형광색 표시를 하며 일치하는 키워드를 보여줘야함
                            matchedKeywords.append(pianoKeyword)
                        }
                    }
                    
                    if !matchedKeywords.isEmpty {
                        showAssistView()
                        return
                    }
                }
            }
        }
        
        hideAssistView()
        
    }
    
    private func showAssistView() {
        view.addSubview(assistTableView)
        assistTableView.frame = CGRect(x: 0, y: 100, width: 330, height: 40 * matchedKeywords.count)
        assistTableView.reloadData()
    }
    
    private func hideAssistView() {
        assistTableView.removeFromSuperview()
    }

}

