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
        let cell = textView.dequeueReusableCell(withIdentifier: attachment.identifier)
        
        if let configuarableCell = cell as? AttributeModelConfigurable,
            let attachmentWithAttribute = attachment as? AttributeContainingAttachment {
            
            if case let .image(imageAttribute)? = attachmentWithAttribute.attribute,
                let realm = try? Realm() {
                //update Cache
                if realm.object(ofType: RealmImageModel.self, forPrimaryKey: imageAttribute.id) == nil {
                    LocalImageCache.shared.updateThumbnailCacheWithID(id: imageAttribute.id + "thumb",
                                                                      width: imageAttribute.size.width,
                                                                      height: imageAttribute.size.height) { (_) in
                                                                        DispatchQueue.main.async { [weak textView] in
                                                                            textView?.reload(attachmentID: attachment.uniqueID)
                                                                        }
                    }
                    return cell
                }
            }
            
            configuarableCell.configure(with: attachmentWithAttribute.attribute)
            
        }
        
        return cell
    }
    
    
}
