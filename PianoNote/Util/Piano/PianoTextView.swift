//
//  PianoTextView.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import InteractiveTextEngine_iOS

class PianoTextView: InteractiveTextView {
    
    private(set) var inputViewManager: DRInputViewManager!
    var isSyncing: Bool = false
    var noteID: String!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        inputViewManager = DRInputViewManager(self)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if inputViewManager.magnifyAccessoryView.magnifyView.state == .paste {
            return action == #selector(paste(_:))
        }
        inputViewManager.magnifyAccessoryView.magnifyView.cursor()
        return true
    }

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

extension PianoTextView {
    func set(string: String, with attributes: [AttributeModel]) {
        let newAttributedString = NSMutableAttributedString(string: string)
        attributes.forEach{ newAttributedString.add(attribute: $0) }
        
        attributedText = newAttributedString
    }
    
    func get() -> (string: String, attributes: [AttributeModel]) {
        
        return attributedText.getStringWithPianoAttributes()
    }
}
