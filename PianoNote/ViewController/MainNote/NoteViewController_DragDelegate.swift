//
//  NoteViewController_DragDelegate.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 13..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import InteractiveTextEngine_iOS

@available(iOS 11.0, *)
extension NoteViewController: UITextDragDelegate, UITextDropDelegate {
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, itemsForDrag dragRequest: UITextDragRequest) -> [UIDragItem] {
        let location = textView.offset(from: textView.beginningOfDocument, to: dragRequest.dragRange.start)
        let length = textView.offset(from: dragRequest.dragRange.start, to: dragRequest.dragRange.end)
        
        let attributedString = NSAttributedString(attributedString:
            textView.textStorage.attributedSubstring(from: NSMakeRange(location, length)))
        
        let itemProvider = NSItemProvider(object: attributedString)
        
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = dragRequest.dragRange
        
        return [dragItem]
    }
    
    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragPreviewForLiftingItem item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        guard let textRange = item.localObject as? UITextRange else { return nil }
        let location = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let length = textView.offset(from: textRange.start, to: textRange.end)
        let range = NSMakeRange(location, length)
        
        let preview: UIView
        let bounds = textView.layoutManager.boundingRect(forGlyphRange: range, in: textView.textContainer)
        if let attachment = textView.attributedText.attribute(.attachment, at: range.location, effectiveRange: nil) as? InteractiveTextAttachment {
            //make it blurred
            preview = UIImageView(image: attachment.getPreviewForDragInteraction())
        } else {
            preview = UILabel(frame: bounds)
            (preview as! UILabel).attributedText = textView.textStorage.attributedSubstring(from: range)
        }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let target = UIDragPreviewTarget(container: textView, center: center)
        
        return UITargetedDragPreview(view: preview, parameters: UIDragPreviewParameters(), target: target)
    }
    
    func textDroppableView(_ textDroppableView: UIView & UITextDroppable, willBecomeEditableForDrop drop: UITextDropRequest) -> UITextDropEditability {
        
        return (textView.isSyncing || isSaving) ? .no : .yes
    }
    
    func textDroppableView(_ textDroppableView: UIView & UITextDroppable, proposalForDrop drop: UITextDropRequest) -> UITextDropProposal {
        return UITextDropProposal(operation: .move)
    }
    
    
    func textDroppableView(_ textDroppableView: UIView & UITextDroppable, dropSessionDidEnd session: UIDropSession) {
        saveText()
    }
}

@available(iOS 11.0, *)
extension NoteViewController: UITextPasteDelegate {
    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, combineItemAttributedStrings itemStrings: [NSAttributedString], for textRange: UITextRange) -> NSAttributedString {
        
        if itemStrings.count == 1 {
            let attributedString = itemStrings[0]
            
            if let attachment = attributedString.attribute(.attachment, at: 0, effectiveRange: nil) as? InteractiveTextAttachment {
                let newAttr = NSAttributedString(attachment: attachment.getCopyForDragInteraction())
                return newAttr
            }
        }
        
        return itemStrings.reduce(NSMutableAttributedString()) { (result, attr) -> NSMutableAttributedString in
            result.append(attr)
            return result
        }
    }
}
