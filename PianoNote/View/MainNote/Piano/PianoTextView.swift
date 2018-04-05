//
//  PianoTextView.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class PianoTextView: UITextView {

    override var typingAttributes: [String : Any] {
        get {
            
            var attributes: [String : Any] = [:]
            FormAttributes.defaultAttributes.forEach { (key, value) in
                attributes[key.rawValue] = value
            }
            return attributes

        } set {

        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        tag = ViewTag.PianoTextView.rawValue
        textContainerInset.top = 20
        
        
    }
    
//    override func replacementObject(for aCoder: NSCoder) -> Any? {
//
//        let textViewST = PianoTextView(coder: aCoder)
//
//
//        let textView
//
//    }
    
    private func setup() {
        textContainer.lineFragmentPadding = 0
        
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        resetConstraints()
        
    }

}

extension PianoTextView {
    
    /**
     개발자가 어떻게 컨스트레인트를 지정했더라도 다시 피아노에 맞춰 새롭게 지정해줌
     */
    private func resetConstraints() {
        
        removeAllConstraints()
        
        self.snp.makeConstraints { [weak self](make) in
            guard let superView = self?.superview else { return }
            
            make.top.equalTo(superView).labeled(ConstraintIdentifier.pianoTextViewTop)
            make.bottom.equalTo(superView).labeled(ConstraintIdentifier.pianoTextViewBottom)
            if #available(iOS 11.0, *) {
                make.left.right.equalTo(superView.safeAreaLayoutGuide)
            } else {
                make.left.right.equalTo(superView)
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
