//
//  DRMagnifyView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/// 확대경의 상태 구분.
enum MagnifyState {
    case normal, tapped, paste
}

class DRMagnifyView: UIScrollView {
    
    private weak var targetView: UITextView!
    
    private let tapGesture = UITapGestureRecognizer()
    private let doubleTapGesture = UITapGestureRecognizer()
    private let longPressGesture = UILongPressGestureRecognizer()
    
    private let selectionView = UIView()
    private let cursorView = UIView()
    private let mirrorView = UILabel()
    
    private var mLineAttr = NSMutableAttributedString(string: "")
    private var frontRange = NSMakeRange(0, 0)
    private var cursorInset: CGFloat = 4
    
    private var magnifyState = MagnifyState.normal
    var state: MagnifyState {return magnifyState}
    
    convenience init(_ targetView: UITextView?) {
        self.init()
        self.targetView = targetView
        initView()
        device(orientationDidChange: { _ in self.scroll()})
    }
    
    private func initView() {
        backgroundColor = UIColor(hex6: "fafafa")
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = .white
        bounces = false
        
        tapGesture.addTarget(self, action: #selector(action(tap:)))
        addGestureRecognizer(tapGesture)
        doubleTapGesture.addTarget(self, action: #selector(action(doubleTap:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        longPressGesture.addTarget(self, action: #selector(action(longPress:)))
        addGestureRecognizer(longPressGesture)
        
        selectionView.backgroundColor = UIColor(hex6: "CCDDED")
        addSubview(selectionView)
        
        cursorView.backgroundColor = UIColor(hex6: "567BF3")
        cursorView.isHidden = true
        addSubview(cursorView)
        
        mirrorView.backgroundColor = .clear
        mirrorView.textColor = .black
        mirrorView.isHidden = true
        addSubview(mirrorView)
        
        mirrorView.font = UIFont.preferred(font: 28, weight: .regular)
        mirrorSizetoFit()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.cursorView.isHidden = false
            self.cursor()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if layer.cornerRadius == 0 {
            layer.cornerRadius = bounds.height / 2
            layer.borderColor = UIColor(hex6: "c7c7cc").cgColor
            layer.borderWidth = 1
        }
        // Cursor를 화면 중간에 위치하도록 하는 inset.
        if contentInset.left == 0 {
            let offset = mainSize.width / 2 - bounds.width / 2 - frame.origin.x
            contentInset.left = bounds.width / 2 + offset
            contentInset.right = bounds.width / 2 - offset
        }
    }
    
}

// Sync function extension.
extension DRMagnifyView {
    
    typealias TextRange = (text: String, range: NSRange)
    
    /// PianoView와 KeyboardView의 sync 작업을 진행.
    func sync() {
        guard magnifyState != .tapped else {return}
        
        //targetView의 cursor에 따른 text 및 range 추출.
        let textRange = extractText()
        checkAttachment()
        
        // mirrorView에 text적용 및 size 처리.
        mirrorView.text = textRange.text
        mirrorSizetoFit()
        
        // 커서의 앞부분 range.
        frontRange = NSMakeRange(0, targetView.selectedRange.location - textRange.range.location)
        scroll()
        selection()
        cursor()
    }
    
    /// targetView의 cursor가 위치한 text의 paragraph가 가지는 range의 string을 추출한다.
    private func extractText() -> TextRange {
        let lineRange = (targetView.text as NSString).paragraphRange(for: targetView.selectedRange)
        let lineAttr = targetView.textStorage.attributedSubstring(from: lineRange)
        mLineAttr = NSMutableAttributedString(attributedString: lineAttr)
        mLineAttr.addAttributes([NSAttributedStringKey.font : mirrorView.font], range: NSMakeRange(0, lineAttr.length))
        return TextRange(text: mLineAttr.string, range: lineRange)
    }
    
    /// text가 없거나 Attachment일때는 keyboardView를 hidden 처리한다.
    private func checkAttachment() {
        mirrorView.isHidden = (mLineAttr.containsAttachments(in: NSMakeRange(0, mLineAttr.length)) || mLineAttr.length <= 0)
    }
    
    /// mirrorView에 담겨있는 text size에 맞춰 width를 결정한다.
    private func mirrorSizetoFit() {
        mirrorView.sizeToFit()
        contentSize.width = mirrorView.frame.size.width
        mirrorView.frame.size.height = bounds.height
    }
    
    /// cursor가 중앙에 고정 될 수 있도록 auto scrolling을 진행한다.
    private func scroll() {
        let frontWidth = mLineAttr.attributedSubstring(from: frontRange).size().width
        contentOffset.x = frontWidth - (mainSize.width / 2 - frame.origin.x)
    }
    
    /// targetView의 cursor 또는 user가 KeyboardView를 tap한 location에 따라 cursor 위치를 변경한다.
    func cursor(_ point: CGPoint? = nil) {
        /// mirrorView의 cursor 작업.
        func mirrorCursor(_ range: NSRange) {
            cursorView.alpha = 1
            cursorView.frame = CGRect(x: mLineAttr.attributedSubstring(from: range).size().width, y: cursorInset, width: 2, height: bounds.height - (cursorInset * 2))
            UIView.animate(withDuration: 0.5, delay: 0.35, options: [UIViewAnimationOptions.repeat, .autoreverse], animations: {
                self.cursorView.alpha = 0
            })
        }
        
        // User interact로 point가 넘어왔는지에 따른 구분.
        if let point = point {
            selectionView.isHidden = true
            cursorView.isHidden = false
            
            // point로 index 및 range 추출.
            let indexGlyph = glyphIndex(from: point)
            let cursorRange = NSMakeRange(0, indexGlyph)
            let frontText = mLineAttr.attributedSubstring(from: cursorRange).string
            let lineRange = (targetView.text as NSString).paragraphRange(for: targetView.selectedRange)
            
            if let lastChar = frontText.last, lastChar == "\n" {
                targetView.selectedRange.location = lineRange.location + indexGlyph - 1
            } else {
                targetView.selectedRange.location = lineRange.location + indexGlyph
            }
            mirrorCursor(cursorRange)
        } else {
            mirrorCursor(frontRange)
        }
    }
    
    /// targetView의 selectedTextRange에 따라 keyboardView에도 selection effect를 부여한다
    private func selection() {
        guard let selectedTextRange = targetView.selectedTextRange else {return}
        if !selectedTextRange.isEmpty {
            let originX = mLineAttr.attributedSubstring(from: frontRange).size().width
            let selectedTextLength = targetView.offset(from: selectedTextRange.start, to: selectedTextRange.end)
            let selectedRange = NSMakeRange(frontRange.length, selectedTextLength)
            let selectedText = mLineAttr.attributedSubstring(from: selectedRange)
            selectionView.frame = CGRect(x: originX, y: 0, width: selectedText.size().width, height: bounds.height)
            
            // selectedTextRange가 newlines을 가지면 hidden 처리
            mirrorView.isHidden = selectedText.string.rangeOfCharacter(from: .newlines) != nil
        }
        selectionView.isHidden = selectedTextRange.isEmpty
        cursorView.isHidden = !selectedTextRange.isEmpty
    }
    
}

// User action extension
extension DRMagnifyView {
    
    @objc private func action(tap: UITapGestureRecognizer) {
        guard !targetView.text.isEmpty else {return}
        magnifyState = .tapped
        cursor(tap.location(in: self))
        magnifyState = .normal
    }
    
    @objc private func action(doubleTap: UITapGestureRecognizer) {
        let textView = customTextView(bounds: mirrorView.bounds, attributedString: mLineAttr)
        if let wordRange = textView.word(from: doubleTap.location(in: self)) {
            magnifyState = .tapped
            UIPasteboard.general.string = wordRange.word.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 복사되는 word에 selection effect 적용
            let wordRect = textView.firstRect(for: wordRange.range)
            let origin = CGPoint(x: wordRect.origin.x, y: cursorInset)
            let size = CGSize(width: wordRect.width, height: bounds.height - (cursorInset * 2))
            selectionView.frame = CGRect(origin: origin, size: size)
            
            selectionView.alpha = 0
            selectionView.isHidden = false
            UIView.animate(withDuration: 0.25, delay: 0, options: [.autoreverse], animations: {
                self.selectionView.alpha = 1
            }, completion: { finished in
                self.selectionView.isHidden = true
            })
            magnifyState = .normal
        }
    }
    
    @objc private func action(longPress: UITapGestureRecognizer) {
        switch longPress.state {
        case .began, .changed:
            guard !targetView.text.isEmpty else {return}
            magnifyState = .tapped
            cursor(longPress.location(in: self))
            magnifyState = .normal
        case .ended:
            magnifyState = .paste
            UIMenuController.shared.setTargetRect(bounds, in: self)
            UIMenuController.shared.setMenuVisible(true, animated: true)
            magnifyState = .normal
        case .possible, .cancelled, .failed:
            break
        }
    }
    
}

// Helper function extension
extension DRMagnifyView {
    
    /**
     Point to mirrorView text's glyphIndex
     - parameter point : 찾고자 하는 point
     - returns : 해당 point의 text glyphIndex
     */
    func glyphIndex(from point: CGPoint) -> Int {
        guard !mLineAttr.string.isEmpty else {return 0}
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: mLineAttr)
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: mirrorView.bounds.size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        
        let locationZero = layoutManager.location(forGlyphAt: 0)
        let index = layoutManager.glyphIndex(for: CGPoint(x: locationZero.x + point.x, y: 0), in: textContainer)
        let glyphLocation = layoutManager.location(forGlyphAt: index + 1)
        var result = layoutManager.glyphIndex(for: CGPoint(x: glyphLocation.x, y: 0), in: textContainer)
        
        if point.x < 0 { // 터치영역이 왼쪽 끝 넘어일때 0으로 고정
            result = 0
        } else if index == result { // 터치영역이 오른쪽 끝 너머일때는 가지고 있는 glyph length로 고정
            result = layoutManager.glyphRange(for: textContainer).length
        }
        return result
    }
    
    /**
     특정 bounds와 attr을 가지는 custom textView를 구현한다
     - parameter bounds : 적용하고자 하는 bounds rect
     - parameter attributedString : 입력하고자 하는 attrString
     - returns : Custom textView
     */
    func customTextView(bounds: CGRect, attributedString: NSAttributedString) -> UITextView {
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)
        return UITextView(frame: bounds, textContainer: textContainer)
    }
    
}

