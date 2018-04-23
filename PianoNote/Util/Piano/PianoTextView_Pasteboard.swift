//
//  PianoTextView_Pasteboard.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 23..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RealmSwift
import MobileCoreServices
import InteractiveTextEngine_iOS

extension PianoTextView {
    override func copy(_ sender: Any?) {
        guard let realm = try? Realm() else {return}
        
        let selectedAttributedString = NSMutableAttributedString(attributedString: self.attributedText.attributedSubstring(from: selectedRange))
        
        selectedAttributedString.enumerateAttribute(.attachment, in: NSMakeRange(0, selectedAttributedString.length),
                                                    options: .longestEffectiveRangeNotRequired)
        { value, range, _ in
            if let attachment = value as? ImageAttachment,
                case let .image(imageAttribute)? = attachment.attribute,
                let imageModel = realm.object(ofType: RealmImageModel.self, forPrimaryKey: imageAttribute.id),
                let image = UIImage(data: imageModel.image) {
                
                let resizedImage: UIImage!
                if image.size.width > UIScreen.main.bounds.width {
                    let width = UIScreen.main.bounds.width / 2
                    let height = image.size.height * width / image.size.width
                    resizedImage = image.resizeImage(size: CGSize(width: width, height: height)) ?? UIImage()
                } else {
                    resizedImage = image
                }
                
                
                let newAttachment = NSTextAttachment()
                newAttachment.image = resizedImage
                
                let replacement = NSAttributedString(attachment: newAttachment)
                
                selectedAttributedString.replaceCharacters(in: range, with: replacement)
            } else if let attachment = value as? AttributeContainingAttachment {
                
                let newAttachment = NSTextAttachment()
                newAttachment.contents = try! JSONEncoder().encode(attachment.attribute)
                newAttachment.fileType = "Attribute"
                
                let replacement = NSAttributedString(attachment: newAttachment)
                
                selectedAttributedString.replaceCharacters(in: range, with: replacement)
            }
        }
        
        
        let data = (try? selectedAttributedString.data(from: NSMakeRange(0, selectedAttributedString.length)
            , documentAttributes:[.documentType: NSAttributedString.DocumentType.rtfd])) ?? Data()
        
        
        
        let item:[String: Any] = [kUTTypeFlatRTFD as String: data,
                                  kUTTypeUTF8PlainText as String: selectedAttributedString.string]
        UIPasteboard.general.setItems([item], options: [:])
        
    }
    
    override func cut(_ sender: Any?) {
        copy(sender)
        self.textStorage.deleteCharacters(in: selectedRange)
    }
    
    override func paste(_ sender: Any?) {
        if let attrString = transformAttrStringFromPasteboard() {
            //when setting data transform it
            let pasteString = NSMutableAttributedString(attributedString: attrString)
            pasteString.enumerateAttributes(in: NSMakeRange(0, pasteString.length), options: .longestEffectiveRangeNotRequired, using: { (dic, range, _) in
                if let attachment = dic[.attachment] as? NSTextAttachment {
                    
                    if let image = attachment.image {
                        let resizedImage: UIImage!
                        if image.size.width > UIScreen.main.bounds.width {
                            let width = UIScreen.main.bounds.width / 2
                            let height = image.size.height * width / image.size.width
                            resizedImage = image.resizeImage(size: CGSize(width: width, height: height)) ?? UIImage()
                        } else {
                            resizedImage = image
                        }
                        guard let realm = try? Realm(),
                            let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
                        
                        let newImageModel = RealmImageModel.getNewModel(noteRecordName: noteModel.recordName, image: resizedImage)
                        ModelManager.saveNew(model: newImageModel) { error in }
                        
                        let imageAttribute = ImageAttribute(id: newImageModel.id, size: resizedImage.size)
                        let newAttachment = ImageAttachment(attribute: imageAttribute)

                        let attachString = NSAttributedString(attachment: newAttachment)
                        
                        pasteString.replaceCharacters(in: range, with: attachString)
                    } else if let data = attachment.fileWrapper?.regularFileContents {
                        let style = try! JSONDecoder().decode(AttachmentAttribute.self, from: data)
                        var newAttachment: InteractiveTextAttachment? = nil
                        switch style {
                        case .event(let eventAttribute): newAttachment = EventAttachment(attribute: eventAttribute)
                        default: break
                        }
                        if let newAttachment = newAttachment {
                            let attachString = NSAttributedString(attachment: newAttachment)
                            pasteString.replaceCharacters(in: range, with: attachString)
                        }
                        //attachment init해서 replace 하는식으로~
                    }
                }
            })
            
            
            textStorage.replaceCharacters(in: selectedRange, with: pasteString)
        }
    }
    
    private func transformAttrStringFromPasteboard() -> NSAttributedString? {
        var attrString: NSAttributedString? = nil
        
        
        if let data = UIPasteboard.general.data(forPasteboardType: "com.apple.flat-rtfd") {
            
            do {
                attrString = try NSAttributedString(data: data, options: [.documentType:NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else if let data = UIPasteboard.general.data(forPasteboardType: "com.apple/webarchive") {
            do {
                attrString = try NSAttributedString(data: data, options: [:], documentAttributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else if let data = UIPasteboard.general.data(forPasteboardType: "com.evernote.app.htmlData") {
            do {
                attrString = try NSAttributedString(data: data, options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else if let data = UIPasteboard.general.data(forPasteboardType: "Apple Web Archive pasteboard type") {
            do {
                attrString = try NSAttributedString(data: data, options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return attrString
    }
}
