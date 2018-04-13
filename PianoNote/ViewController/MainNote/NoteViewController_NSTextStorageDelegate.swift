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
    //서식이 있는데 넘버링이중
    //willProcessEditing에서 textStorage에 접근해 character를 바꿔도 이 함수가 다시 콜백되지 않기 때문에 여기서 character를 바꿀 수 있음
    //willProcessEditing에서 textStorage에 접근해 attribute를 바꿔도 이 함수가 다시 콜백되지 않기 때문에 여기서 attribute를 바꿀 수 있음
    func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        guard !invokingTextViewDelegate,
            editedMask.rawValue == 3,
            textView.isEditable else { return }
        print("editedRange: \(editedRange), delta: \(delta)")
        //FormManager.textStorage(textStorage, willProcessEditing: editedMask, range: editedRange, changeInLength: delta)
    }
    
}

//TextStorage edit이 호출되는 상황
// 1. paste
// 2. textView.text = ??(물어보기)
// 3. 타이핑 도중
//1. 지오에게 textStorage로 textShouldChange 쓰는 방법 알아보기 -> 내 생각이 맞다면 배킹스토리지가 바뀌기 전이므로, 그걸 기준으로 판단
//2.

