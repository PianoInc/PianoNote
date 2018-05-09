//
//  Keyboard.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

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
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        
        keyboardToken =  UIApplication.shared
            .windows[1].subviews
            .first?.subviews
            .first?.layer.observe(\.position,
                           changeHandler: { [weak self] (layer, change) in
                            guard let strongSelf = self else { return }
                            strongSelf.view.constraints.forEach({ (constraint) in
                                if constraint.identifier == ConstraintIdentifier.pianoTextViewBottom {
                                    constraint.constant = max(strongSelf.view.bounds.height - layer.position.y, 0)
                                }
                            })
            })
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.constraints.forEach({ (constraint) in
                if constraint.identifier == ConstraintIdentifier.pianoTextViewBottom {
                    constraint.constant = kbHeight
                    self?.view.layoutIfNeeded()
                    return
                }
            })
        })

    }
    
    @objc func keyboardDidHide(notification: Notification) {
        keyboardToken = nil
    }
    
}
