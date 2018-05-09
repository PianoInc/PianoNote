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

    var isSyncing: Bool = false
    var noteID: String = ""
    var matchedKeywords: [PianoKeyword] = []
    
    override var keyCommands: [UIKeyCommand]? {
        
        guard hasSubView(tag: ViewTag.PianoAssistTableView) else { return [] }
        //TODO: 여기서 분기처리하기
        
        return [
            UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: #selector(upArrow(sender:))),
            UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: #selector(downArrow(sender:))),
            UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: #selector(escape(sender:))),
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(newline(sender:)))
        ]
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
        tag = ViewTag.PianoTextView.rawValue
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
        
        newTextView.tag = ViewTag.PianoTextView.rawValue
        
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




//MARK: AssistView
extension PianoTextView {
    
    @objc func newline(sender: UIKeyCommand) {
        replaceProcess()
    }
    
    internal func replaceProcess() {
        
        guard let tableView = subView(tag: ViewTag.PianoAssistTableView) as? PianoAssistTableView,
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: selectedIndexPath) as? PianoAssistTableViewCell,
            let text = cell.titleLabel.text,
            let textRange = textRangeAfterSharp() else { return }
        
        textStorage.replaceCharacters(in: textRange, with: text)
        selectedRange.location += (text.count - textRange.length)
        
        
        hideAssistViewIfNeeded()
    }
    
    @objc func escape(sender: UIKeyCommand) {
        hideAssistViewIfNeeded()
    }
    
    @objc func upArrow(sender: UIKeyCommand) {
        
        guard let tableView = subView(tag: ViewTag.PianoAssistTableView) as? PianoAssistTableView,
            let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.row == 0 {
            newIndexPath = IndexPath(row: numberOfRows - 1, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.row - 1, section: 0)
        }
        
        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .none)
        
    }
    
    @objc func downArrow(sender: UIKeyCommand) {
        
        guard let tableView = subView(tag: ViewTag.PianoAssistTableView) as? PianoAssistTableView,
            let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        let newIndexPath: IndexPath
        if selectedIndexPath.row + 1 == numberOfRows {
            newIndexPath = IndexPath(row: 0, section: 0)
        } else {
            newIndexPath = IndexPath(row: selectedIndexPath.row + 1, section: 0)
        }
        
        tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .none)
        
    }
    
    private func textRangeAfterSharp() -> NSRange? {
        let paraRange = (text as NSString).paragraphRange(for: selectedRange)
        let regex = "^\\s*(#)(?=)"
        if let (_, range) = text.detect(searchRange: paraRange, regex: regex),
            selectedRange.location >= range.location + 1 {
            
            return NSMakeRange(range.location + 1, selectedRange.location - (range.location + 1))
        }
        return nil
    }
    
    internal func showAssistViewIfNeeded(_ textView: UITextView, caretRect: CGRect) {
        
        matchedKeywords = []
        guard let text = textView.text,
            let textRange = textRangeAfterSharp() else {
                hideAssistViewIfNeeded()
                return
        }
        
        let matchedText = (text as NSString).substring(with: textRange)
        
        if matchedText.isEmpty {
            //전체 키워드를 대입
            matchedKeywords = PianoCard.keywords
            showAssistView(caretRect)
            
            return
            
        } else {
            for pianoKeyword in PianoCard.keywords {
                if pianoKeyword.keyword.hangul.contains(matchedText.hangul) {
                    //TODO: 일치하는 글자에 형광색 표시를 하며 일치하는 키워드를 보여줘야함
                    matchedKeywords.append(pianoKeyword)
                }
            }
            
            if !matchedKeywords.isEmpty {
                showAssistView(caretRect)
                return
            }
        }
        
        hideAssistViewIfNeeded()
        
    }
    
    
    internal func showAssistView(_ caretRect: CGRect) {
        if let assistView = createSubviewIfNeeded(tag: ViewTag.PianoAssistTableView) as? PianoAssistTableView {
            assistView.setup(textView: self)
            addSubview(assistView)
            assistView.setPosition(textView: self, at: caretRect)
        }
    }
    
    internal func hideAssistViewIfNeeded() {
        subView(tag: ViewTag.PianoAssistTableView)?.removeFromSuperview()
    }
    
}
