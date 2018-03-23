//
//  Keyboard.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import SnapKit

extension NoteTextView {
    
    internal func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    internal func unRegisterKeyboardNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.height,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let superView = superview else { return }
        UIView.animate(withDuration: duration, animations: {
            superView.constraints.forEach({ (constraint) in
                if constraint.identifier == ConstraintIdentifier.pianoTextViewBottom {
                    constraint.constant = kbHeight
                    superView.layoutIfNeeded()
                    return
                }
            })
        })
        
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue,
            let superView = superview else { return }
        UIView.animate(withDuration: duration) {
            superView.constraints.forEach({ (constraint) in
                if constraint.identifier == ConstraintIdentifier.pianoTextViewBottom {
                    constraint.constant = 0
                    superView.layoutIfNeeded()
                    return
                }
            })
        }
        
    }
    
    //뒤에 이미지뷰를 붙여서 혹시나 키보드를 쓸어 내렸을 경우에 피아노 포스터 이미지 보여주기(성능의 이유로 보여지는 텍스트뷰 영역을 줄이기 위함)
    @objc private func keyboardDidShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.height else { return }
        attachBackingImageView(height: kbHeight)
        
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        detachBackingImageView()
    }
    
    private func attachBackingImageView(height: CGFloat) {
        
        guard let superView = superview,
            let imageView = superView.subView(tag: ViewTag.TempImageView) as? UIImageView else { return }
        superView.insertSubview(imageView, belowSubview: self)
        let num = arc4random_uniform(20) + 1
        imageView.image = UIImage(named: "pianoLogo\(num)")
        
        imageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(superView)
            make.height.equalTo(height)
        }
        
        
    }
    
    private func detachBackingImageView() {
        
        guard let superView = superview,
            let imageView = superView.subView(tag: ViewTag.TempImageView) as? UIImageView else { return }
        imageView.removeFromSuperview()
        
    }
    
}
