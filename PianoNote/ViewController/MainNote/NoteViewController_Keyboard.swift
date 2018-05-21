//
//  Keyboard.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import SnapKit

extension NoteViewController {
    
    internal func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    internal func unRegisterKeyboardNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {

        guard let userInfo = notification.userInfo,
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
        else { return }
        
        keyboardToken =  UIApplication.shared
            .windows[1].subviews
            .first?.subviews
            .first?.layer.observe(\.position,
                           changeHandler: { [weak self] (layer, change) in
                            guard let strongSelf = self else { return }
                            //change inset
                            let currentInset = strongSelf.textView.contentInset
                            let currentScrollInset = strongSelf.textView.scrollIndicatorInsets
                            
                            strongSelf.textView.contentInset = UIEdgeInsets(top: currentInset.top,
                                                                            left: currentInset.left,
                                                                            bottom: max(strongSelf.view.bounds.height - layer.position.y, 0),
                                                                            right: currentInset.right)
                            strongSelf.textView.scrollIndicatorInsets = UIEdgeInsets(top: currentScrollInset.top,
                                                                                     left: currentScrollInset.left,
                                                                                     bottom: max(strongSelf.view.bounds.height - layer.position.y, 0),
                                                                                     right: currentScrollInset.right)
            })
        
        let currentInset = textView.contentInset
        let currentScrollInset = textView.scrollIndicatorInsets
        
        textView.contentInset = UIEdgeInsets(top: currentInset.top, left: currentInset.left,
                                             bottom: currentInset.bottom + kbHeight, right: currentInset.right)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: currentScrollInset.top, left: currentScrollInset.left,
                                                      bottom: currentScrollInset.bottom + kbHeight, right: currentScrollInset.right)
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        keyboardToken = nil
    }
    
}
