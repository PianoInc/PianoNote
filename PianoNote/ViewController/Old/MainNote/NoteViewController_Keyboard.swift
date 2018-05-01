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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    internal func unRegisterKeyboardNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {

        guard let userInfo = notification.userInfo,
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.constraints.forEach({ (constraint) in
                if constraint.identifier == ConstraintIdentifier.pianoTextViewBottom {
                    constraint.constant = -kbHeight
                    self?.view.layoutIfNeeded()
                    return
                }
            })
        })

    }

    @objc func keyboardWillHide(notification: Notification) {

        guard let userInfo = notification.userInfo,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view.constraints.forEach({ (constraint) in
                if constraint.identifier == ConstraintIdentifier.pianoTextViewBottom {
                    constraint.constant = 0
                    self?.view.layoutIfNeeded()
                    return
                }
            })
        }

    }

    //뒤에 이미지뷰를 붙여서 혹시나 키보드를 쓸어 내렸을 경우에 피아노 포스터 이미지 보여주기(성능의 이유로 보여지는 텍스트뷰 영역을 줄이기 위함)
    @objc func keyboardDidShow(notification: Notification) {

        guard let userInfo = notification.userInfo,
            let kbHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        attachBackingImageView(height: kbHeight)

    }

    @objc func keyboardDidHide(notification: Notification) {
        detachBackingImageView()
    }
    
    private func attachBackingImageView(height: CGFloat) {
        
        guard let imageView = view.subView(tag: ViewTag.TempImageView) as? UIImageView else { return }
        view.insertSubview(imageView, belowSubview: textView)
        let num = arc4random_uniform(20) + 1
        imageView.image = UIImage(named: "pianoLogo\(num)")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        
        imageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(height)
        }
        
        
    }
    
    private func detachBackingImageView() {
        
        guard let imageView = view.subView(tag: ViewTag.TempImageView) as? UIImageView else { return }
        imageView.removeFromSuperview()
        
    }
    
}
