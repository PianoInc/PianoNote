//
//  PianoTextView.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import InteractiveTextEngine_iOS

class PianoTextView: InteractiveTextView, Assistable {

    var isSyncing: Bool = false
    var noteID: String = ""
    var assistDataSource: [PianoAssistData] = []
    var assistDatas: [PianoAssistData] = {
        PianoCard.keywords.map {
            return PianoAssistData(keyword: $0, input: "")
        }
    }()
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        
        var commands: [UIKeyCommand] = []
        commands.append(contentsOf: assistableKeyCommands)
        
        return commands
        
    }
    

    override var typingAttributes: [String : Any] {
        get {
            return FormAttributes.defaultTypingAttributes
        } set {

        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setup()
        tag = ViewTag.PianoTextView.hashValue
        noteID = ""
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let newTextView = PianoTextView(frame: self.frame)
  
        //get constraints
        var constraints: Array<NSLayoutConstraint> = []
        self.constraints.forEach {
            let firstItem: AnyObject!, secondItem: AnyObject!
            
            if let unwrappedFirst = $0.firstItem as? InteractiveTextView, unwrappedFirst == self {
                firstItem = self
            } else {
                firstItem = $0.firstItem
            }
            
            if let unwrappedSecond = $0.secondItem as? InteractiveTextView, unwrappedSecond == self {
                secondItem = self
            } else {
                secondItem = $0.secondItem
            }
            
            constraints.append(
                NSLayoutConstraint(item: firstItem,
                                   attribute: $0.firstAttribute,
                                   relatedBy: $0.relation,
                                   toItem: secondItem,
                                   attribute: $0.secondAttribute,
                                   multiplier: $0.multiplier,
                                   constant: $0.constant))
        }
        
        
        
        newTextView.addConstraints(constraints)
        newTextView.autoresizingMask = self.autoresizingMask
        newTextView.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints
        
        
        newTextView.autocorrectionType = self.autocorrectionType
        newTextView.attributedText = self.attributedText
        newTextView.backgroundColor = self.backgroundColor
        newTextView.dataDetectorTypes = self.dataDetectorTypes
        newTextView.returnKeyType = self.returnKeyType
        newTextView.keyboardAppearance = self.keyboardAppearance
        newTextView.keyboardDismissMode = self.keyboardDismissMode
        newTextView.keyboardType = self.keyboardType
        newTextView.alwaysBounceVertical = self.alwaysBounceVertical
        
        newTextView.setup()
        
        newTextView.tag = ViewTag.PianoTextView.hashValue
        
        return newTextView
    }
    
    private func setup() {
        textContainer.lineFragmentPadding = 0
        
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        resetConstraints()
        
    }
    
    func getScreenShot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
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
        newAttributedString.addAttributes(FormAttributes.defaultAttributes, range: NSMakeRange(0, newAttributedString.length))
        attributes.forEach{ newAttributedString.add(attribute: $0) }
        
        set(newAttributedString: newAttributedString)
    }
    
    func get() -> (string: String, attributes: [AttributeModel]) {
        
        return attributedText.getStringWithPianoAttributes()
    }
    
    func resetColors(preset: ColorPreset) {
        let foregroundAttributes = get().attributes.filter{ $0.style == .foregroundColor }
        ColorManager.shared.set(preset: preset)
        FormAttributes.defaultColor = ColorManager.shared.defaultForeground()
        FormAttributes.effectColor = ColorManager.shared.pointForeground()
        
        textStorage.addAttribute(.foregroundColor, value: FormAttributes.defaultColor, range: NSMakeRange(0, textStorage.length))
        foregroundAttributes.forEach { textStorage.add(attribute: $0) }
    }
}
