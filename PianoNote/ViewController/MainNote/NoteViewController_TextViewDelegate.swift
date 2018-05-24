//
//  UITextViewDelegate.swift
//  PianoNote
//
//  Created by Kevin Kim on 29/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import RealmSwift

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
        (textView as? Assistable)?.showAssistViewIfNeeded()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        (textView as? Assistable)?.hideAssistViewIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            if let attachment = InteractiveAttachmentModel(text: textView.text, selectedRange: textView.selectedRange) {
                
                if attachment.type == .image {
                    
                    guard let realm = try? Realm(), let noteRecordName = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID)?.recordName else { return true }
                    
                    let imageModel = RealmImageModel.getNewModel(noteRecordName: noteRecordName, image: UIImage(named: "addPeople")!)
                    ModelManager.saveNew(model: imageModel)
                    let cardAttachment = CardAttachment(idForModel: imageModel.id, cellIdentifier: PianoTextImageCell.reuseIdentifier)
                    textView.textStorage.replaceCharacters(in: attachment.paraRange, with: NSAttributedString(attachment: cardAttachment))
                    
                }
                
                
            }
        }
        return true
        
    }
    

    
    /*
     
     if let card = PianoCard(
     text: string,
     selectedRange: NSMakeRange(cursorLocation, 0)) {
     
     //카드가 있다면 붙여주기
     //                let attachment = card.attachment()
     //개행을 추가해 붙이기
     let newLine = "\n"
     
     //붙이기
     //                backingStore.replaceCharacters(in: <#T##NSRange#>, with: <#T##NSAttributedString#>)
     
     
     endEditing()
     return
     }
     
     */
    

   

}

