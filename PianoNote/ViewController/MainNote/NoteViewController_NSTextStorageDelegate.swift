//
//  NoteViewController_NSTextStorageDelegate.swift
//  PianoNote
//
//  Created by Kevin Kim on 29/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

extension NoteViewController: NSTextStorageDelegate {
    

    
    //서식이 없다면, 일반 폰트로 진행
    //서식이 있는데, 마침 서식이고, 넘버링이라면, avenirNext로 폰트 세팅
    //서식이 있는데 넘버링이
    
    //willProcessEditing에서 textStorage에 접근해 character를 바꿔도 이 함수가 다시 콜백되지 않기 때문에 여기서 character를 바꿀 수 있음
    //willProcessEditing에서 textStorage에 접근해 attribute를 바꿔도 이 함수가 다시 콜백되지 않기 때문에 여기서 attribute를 바꿀 수 있음
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        guard !invokingTextViewDelegate,
            editedMask.rawValue == 3,
            textView.isEditable else { return }
   
        guard delta > 0 else { return }
        
        let font: UIFont
        if let pianoBullet = PianoBullet(text: textStorage.string, selectedRange: editedRange) {
            switch pianoBullet.string {
            case "♩":
                font = UIFont.preferredFont(forTextStyle: .title3)
            case "♪":
                font = UIFont.preferredFont(forTextStyle: .title2)
            case "♫":
                font = UIFont.preferredFont(forTextStyle: .title1)
            default:
                font = UIFont.preferredFont(forTextStyle: .body)
            }
        } else {
            font = UIFont.preferredFont(forTextStyle: .body)
        }
        
        textStorage.addAttributes([.font : font], range: editedRange)
        
        //문단 서식 검사를 하고, 대체해야할 게 있다면 대체하기
        //서식 사이에 글자가 들어가면 숫자 + 점의 경우 색상을 풀고 폰트를 바꿔줘야 하며, 특수문자의 경우 대체하고 색상을 바꿔야함
        
    }

}




