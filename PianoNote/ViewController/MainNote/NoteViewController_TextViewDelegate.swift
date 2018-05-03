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
    
}

