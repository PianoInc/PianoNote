//
//  MainTextView.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import SnapKit

class NoteTextView: UITextView {

    var pianoMode: Bool = false {
        didSet { set(for: pianoMode) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        registerKeyboardNotification()
        
    }
    
    deinit {
        unRegisterKeyboardNotification()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        resetConstraints()
        
    }

}

extension NoteTextView {
    
    private func set(for pianoMode: Bool) {
        
        isEditable = !pianoMode
        isSelectable = !pianoMode
        animateSelf()
        animateNavigationBarIfNeeded(for: pianoMode)
        animateToolbar(for: pianoMode)
        setAnimatableTextsView(for: pianoMode)
        setSegmentControl(for: pianoMode)
        setControlView(for: pianoMode)
        
    }
    
    private func animateSelf(){
        
        guard let superView = superview else { return }
        superView.constraints.forEach { (constraint) in
            if let identifier = constraint.identifier,
                identifier == ConstraintIdentifier.pianoTextViewTop {
                constraint.constant = pianoMode ? 100 : 0
                UIView.animate(withDuration: 0.3) {
                    superView.layoutIfNeeded()
                }
                return
            }
        }
        
    }
    
    private func animateNavigationBarIfNeeded(for pianoMode: Bool) {
        
        AppNavigator.currentNavigationController?
            .setNavigationBarHidden(pianoMode, animated: true)
        
    }
    
    private func animateToolbar(for pianoMode: Bool) {
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil)
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(tapDone(sender:)))
        let info = UIBarButtonItem(
            image: UIImage(named: "info"),
            style: .plain,
            target: self,
            action: #selector(tapInfo(sender:)))
        
        AppNavigator.currentViewController?.setToolbarItems([flexibleSpace, done, flexibleSpace, info], animated: false)
        AppNavigator.currentNavigationController?
            .setToolbarHidden(!pianoMode, animated: true)
    }
    
    @objc func tapDone(sender: Any) {
        pianoMode = false
    }
    
    @objc func tapInfo(sender: Any) {
        
    }
    
    private func setSegmentControl(for pianoMode: Bool) {
        
        guard let superView = superview else { return }
        if pianoMode {
            guard let segmentControl = superView.subView(tag: ViewTag.PianoSegmentControl) as? PianoSegmentControl,
                let animatableTextsView = superView.subView(tag: ViewTag.AnimatableTextsView) as? AnimatableTextsView else { return }
            superView.insertSubview(segmentControl, belowSubview: self) //TODO: removefromSuperView 안하고 곧바로 다시 삽입해도 되는 지 체크하기
            segmentControl.animatableTextsView = animatableTextsView
            segmentControl.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(superView)
                make.height.equalTo(100)
            })
            
        } else {
            UIView.transition(with: superView, duration: 0.33, options: [.transitionCrossDissolve], animations: {
                guard let control = superView.viewWithTag(ViewTag.PianoSegmentControl.rawValue) as? PianoSegmentControl else { return }
                control.removeFromSuperview()
            }, completion: nil)

        }
        
    }
    
    private func setAnimatableTextsView(for pianoMode: Bool) {
        
        guard let superView = superview else { return }
        if pianoMode {
            guard let animatableTextsView = superView.subView(tag: ViewTag.AnimatableTextsView) as? AnimatableTextsView else { return }
            animatableTextsView.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalTo(superView)
            })
        } else {
            guard let animatableTextsView = superView.subView(tag: ViewTag.AnimatableTextsView) as? AnimatableTextsView else { return }
            animatableTextsView.removeFromSuperview()
        }
        
    }
    
    private func setControlView(for pianoMode: Bool) {
        
    }
    
}


//MARK: Constraint
extension NoteTextView {
    /**
     개발자가 어떻게 컨스트레인트를 지정했더라도 다시 피아노에 맞춰 새롭게 지정해줌
     */
    private func resetConstraints() {
        
        removeAllConstraints()
        
        self.snp.makeConstraints { [weak self](make) in
            guard let superView = self?.superview else { return }
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(superView).labeled(ConstraintIdentifier.pianoTextViewTop)
                make.left.equalTo(superView.safeAreaLayoutGuide.snp.left)
                make.right.equalTo(superView.safeAreaLayoutGuide.snp.right)
                make.bottom.equalTo(superView).labeled(ConstraintIdentifier.pianoTextViewBottom)
            } else {
                make.top.equalTo(superView)
                make.left.equalTo(superView)
                make.right.equalTo(superView)
                make.bottom.equalTo(superView)
            }
        }
    }
    
    private func removeAllConstraints() {
        guard let superView = superview else { return }
        
        self.removeConstraints(self.constraints)
        
        superView.constraints.forEach { (constraint) in
            
            if let item = constraint.firstItem as? NSObject, item == self {
                
                superView.removeConstraint(constraint)
            } else if let item = constraint.secondItem as? NSObject, item == self {
                
                superView.removeConstraint(constraint)
            }
        }
    }

}
