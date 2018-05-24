//
//  InteractiveAttachmentCell.swift
//  InteractiveTextEngine
//
//  Created by 김범수 on 2018. 3. 22..
//

import Foundation

class InteractiveAttachmentCellDispatcher {

    weak var superView: InteractiveTextView?

    //reuse identifier: Nibs
    private var nibs: [String: UINib] = [:]
    
    // identifier: array of cells
    //[reuseIdentifier: [uniqueiD: cell]]
    private var idleCells: [String: [String: InteractiveAttachmentCell]] = [:]

    // identifier: array of cells
    //[reuseIdentifier: [uniqueiD: cell]]
    private var workingCells: [String: [String: InteractiveAttachmentCell]] = [:]

    // List of attachments
    //[uniqueiD: attachment]
    private var attachments: [String: InteractiveTextAttachment] = [:]

    func visibleRectChanged(rect: CGRect) {
        //Notify!
        //TODO:Notification
        attachments.values.forEach{ $0.checkForVisibility(visibleBounds: rect) }
    }

    func add(attachment: InteractiveTextAttachment) {
        
        attachment.delegate = self
        attachments[attachment.uniqueID] = attachment
        needToDisplay(attachment: attachment)//for undos
    }

    func remove(attachmentID: String) {
        if let attachment = attachments[attachmentID] {
            attachment.delegate = nil
            needToEndDisplay(attachment: attachment)
        }
        attachments.removeValue(forKey: attachmentID)
    }
    
    func register(nib: UINib?, forCellReuseIdentifier identifier: String) {
        guard let nib = nib else {return}
        nibs[identifier] = nib
        
        idleCells[identifier] = [:]
        workingCells[identifier] = [:]
    }
    
    func dequeueReusableCell(withIdentifier identifier: String) -> InteractiveAttachmentCell {
        
        if let cell = idleCells[identifier]?.popFirst() {
            cell.value.prepareForReuse()
            
            return cell.value
        } else {
            guard let nib = nibs[identifier],
                let textView = superView else {fatalError("Nib is not registered for identifier\"\(identifier)\"")}
        
            for object in nib.instantiate(withOwner: nil, options: nil) {
                if let cell = object as? InteractiveAttachmentCell {
                    
                    
                    cell.isUserInteractionEnabled = true
                    cell.translatesAutoresizingMaskIntoConstraints = false
                    cell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    textView.addSubview(cell)
                    
                    cell.leadingConstraint = NSLayoutConstraint(item: cell, attribute: .leading, relatedBy: .equal,
                                                               toItem: textView, attribute: .leading, multiplier: 1.0, constant: 0.0)
                    cell.topConstraint = NSLayoutConstraint(item: cell, attribute: .top, relatedBy: .equal,
                                                            toItem: textView, attribute: .top, multiplier: 1.0, constant: 0.0)
                    cell.widthConstraint = NSLayoutConstraint(item: cell, attribute: .width, relatedBy: .equal,
                                                              toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
                    cell.heightConstraint = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal,
                                                               toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
                    
                    NSLayoutConstraint.activate([cell.leadingConstraint!, cell.topConstraint!,
                                                 cell.widthConstraint!, cell.heightConstraint!])
                    idleCells[identifier]?[cell.uniqueID] = cell
                    cell.reuseIdentifier = identifier
                    
                    cell.prepareForReuse()
                    
                    return cell
                }
            }
            fatalError("There is no InteractiveAttachmentCell class registered in Nib \(nib.description)")
        }
    }
    
    func reload(attachmentID: String) {
        guard let attachment = attachments[attachmentID] else {return}
        needToEndDisplay(attachment: attachment)
        needToDisplay(attachment: attachment)
    }
    
}

extension InteractiveAttachmentCellDispatcher: InteractiveTextAttachmentDelegate {
    
    func needToDisplay(attachment: InteractiveTextAttachment) {
        if attachment.relatedCell != nil { return }
        //get cell from delegate
        guard let textView = superView,
            let currentBounds = attachment.currentBounds,
            let cell = textView.interactiveDataSource?.textView(textView, attachmentForCell: attachment) else {return}
        
        
        workingCells[cell.reuseIdentifier]?[cell.uniqueID] = cell
        idleCells[cell.reuseIdentifier]?.removeValue(forKey: cell.uniqueID)
        
        //link cell with attribute
        cell.relatedAttachment = attachment
        attachment.relatedCell = cell
        
        //willDisplayCell
        textView.interactiveDelegate?.textView?(textView, willDisplay: cell)
        //sync frame
        
        let containerInset = textView.textContainerInset
        
        let cellBounds = currentBounds.offsetBy(dx: containerInset.left, dy: containerInset.top).insetBy(dx: 1.5, dy: 0)
        cell.leadingConstraint?.constant = cellBounds.minX
        cell.topConstraint?.constant = cellBounds.minY
        cell.widthConstraint?.constant = cellBounds.width
        cell.heightConstraint?.constant = cellBounds.height
        
        cell.isHidden = false
        
        //didDisplayCell
        textView.interactiveDelegate?.textView?(textView, didDisplay: cell)
    }

    func needToEndDisplay(attachment: InteractiveTextAttachment) {
        guard let textView = superView,
            let cell = attachment.relatedCell else {return}
        
        
        attachment.relatedCell = nil
        cell.relatedAttachment = nil
        
        //willEndDisplayCell
        textView.interactiveDelegate?.textView?(textView, willEndDisplaying: cell)
        
        cell.leadingConstraint?.constant = 0
        cell.topConstraint?.constant = 0
        cell.widthConstraint?.constant = 0
        cell.heightConstraint?.constant = 0
        
        cell.isHidden = true
        
        //get cell and put it in idle
        idleCells[cell.reuseIdentifier]?[cell.uniqueID] = cell
        workingCells[cell.reuseIdentifier]?.removeValue(forKey: cell.uniqueID)
        
        //didEndDisplayCell
        textView.interactiveDelegate?.textView?(textView, didEndDisplaying: cell)
    }
    
    func invalidateDisplay(range: NSRange) {
        DispatchQueue.main.async { [weak self] in
            self?.superView?.layoutManager.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
        }
    }
    
    func boundsGiven(attachment: InteractiveTextAttachment) {
        guard let currentBounds = superView?.visibleBounds else {return}
        attachment.checkForVisibility(visibleBounds: currentBounds)
    }
}


