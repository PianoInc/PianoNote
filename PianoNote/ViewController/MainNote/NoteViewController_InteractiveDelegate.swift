//
//  NoteViewController_InteractiveDelegate.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 13..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import RealmSwift

extension NoteViewController: InteractiveTextViewDelegate, InteractiveTextViewDataSource {
    func textView(_ textView: InteractiveTextView, attachmentForCell attachment: InteractiveTextAttachment) -> InteractiveAttachmentCell {
        let cell = textView.dequeueReusableCell(withIdentifier: attachment.cellIdentifier)
        
        if let configuarableCell = cell as? AttributeModelConfigurable,
            let attachmentWithAttribute = attachment as? CardAttachment {
            
            configuarableCell.configure(with: attachmentWithAttribute.idForModel)
            
        }
        
        return cell
    }
    
    
}
