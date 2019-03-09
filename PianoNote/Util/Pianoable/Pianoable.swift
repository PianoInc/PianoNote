//
//  Pianoable.swift
//  PianoNote
//
//  Created by Kevin Kim on 10/05/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import Foundation
import CoreGraphics
import InteractiveTextEngine_iOS

/**
 
 컨스트레인트의 identifier를 설정해주어야 함: ConstraintIdentifier.pianoTextViewTop
 
 */

extension ViewTag {
    static let PianoButton = "PianoButton"
    static let PianoSegmentControl = "PianoSegmentControl"
    static let PianoView = "PianoView"
    static let PianoControl = "PianoControl"
    static let PianoTextView = "PianoTextView"
    static let PianoCoverView = "PianoCoverView"
}

protocol Pianoable: class where Self: PianoTextView {
    
}

extension Pianoable {
    
    func beginPiano() {
        operate(on: true)
    }
    
    func finishPiano() {
        operate(on: false)
    }

    

}

//MARK: Private

extension Pianoable {
    
    func preparePiano(at touch: Touch) -> AnimatableTextsTrigger {
        return { [weak self] in
            guard let strongSelf = self,
                let info: (rect: CGRect, range: NSRange, attrText: NSAttributedString)
                = strongSelf.animatableInfo(touch: touch) else { return nil }
            
            
            
            //TODO: animatableText == nil 이면 애니메이션 할 필요 없음(텍스트가 없거나, 이미지 문단일 경우)
            guard !strongSelf.attributedText.containsAttachments(in: info.range),
                info.attrText.length != 0 else { return nil }
            
            strongSelf.addCoverView(rect: info.rect)    //cover뷰 추가
            strongSelf.isUserInteractionEnabled = false // effectable 스크롤 안되도록 고정
            
            return strongSelf.generateAnimatableText(info: info)
        }
    }
    
    func endPiano(with result: [PianoResult]) {
        
        setAttributes(with: result)
        removeCoverView()
        isUserInteractionEnabled = true
    }
    
    private func setAttributes(with results: [PianoResult]) {
        
        results.forEach { (result) in
            textStorage.addAttributes(result.attrs, range: result.range)
        }
        
    }
    
    private func exclusiveBulletArea(rect: CGRect, in lineRange: NSRange) -> (CGRect, NSRange) {
        
        var newRect = rect
        var newRange = lineRange
        if let bullet = PianoBullet(text: text, lineRange: lineRange) {
            newRange.length = newRange.length - (bullet.baselineIndex - newRange.location)
            newRange.location = bullet.baselineIndex
            let offset = layoutManager.location(forGlyphAt: bullet.baselineIndex).x
            newRect.origin.x += offset
            newRect.size.width -= offset
        }
        return (newRect, newRange)
        
    }
    
    private func animatableInfo(touch: UITouch) -> (CGRect, NSRange, NSAttributedString)? {
        guard attributedText.length != 0 else { return nil }
        var point = touch.location(in: self)
        point.y -= textContainerInset.top
        let index = layoutManager.glyphIndex(for: point, in: textContainer)
        var lineRange = NSRange()
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
        let (rect, range) = exclusiveBulletArea(rect: lineRect, in: lineRange)
        let attrText = attributedText.attributedSubstring(from: range)
        return (rect, range, attrText)
        
    }
    
    private func generateAnimatableText(info: (CGRect, NSRange, NSAttributedString)) -> [AnimatableText] {
        
        let (rect, range, attrText) = info
        return attrText.string.enumerated().map(
            { (index, character) -> AnimatableText in
                var origin = layoutManager.location(forGlyphAt: range.location + index)
                origin.y = rect.origin.y + textContainerInset.top - contentOffset.y
                origin.y += self.frame.origin.y
                origin.x += self.textContainerInset.left
                let text = String(character)
                var attrs = attrText.attributes(at: index, effectiveRange: nil)
                let range = NSMakeRange(range.location + index, 1)
                attrs[.paragraphStyle] = nil
                let attrText = NSAttributedString(string: text, attributes: attrs)
                let label = Label(frame: CGRect(origin: origin, size: CGSize.zero))
                label.attributedText = attrText
                label.sizeToFit()
                
                return AnimatableText(label: label, range: range, rect: label.frame, center: label.center, text: text, attrs: attrs)
                
        })
        
    }
    
    internal func addCoverView(rect: CGRect) {
        var correctRect = rect
        correctRect.origin.y += textContainerInset.top
        let coverView = createSubviewIfNeeded(viewTag: ViewTag.PianoCoverView)
        let control = createSubviewIfNeeded(viewTag: ViewTag.PianoControl)
        coverView.backgroundColor = self.backgroundColor
        coverView.frame = correctRect
        insertSubview(coverView, belowSubview: control)
        
    }
    
    internal func removeCoverView(){
        subView(viewTag: ViewTag.PianoCoverView)?.removeFromSuperview()
        
    }
    
    private func operate(on: Bool) {
        
        setNavigationController(pianoMode: on)
        
        guard let superView = superview,
            let pianoView = (on
                ? superView.createSubviewIfNeeded(viewTag: ViewTag.PianoView)
                : superView.subView(viewTag: ViewTag.PianoView)) as? PianoView,
            let segmentControl = (on
                ? superView.createSubviewIfNeeded(viewTag: ViewTag.PianoSegmentControl)
                : superView.subView(viewTag: ViewTag.PianoSegmentControl)) as? PianoSegmentControl
            else { return }
        
        pianoView.setup(pianoMode: on, to: superView)
        segmentControl.setup(pianoMode: on, to: superView)
        self.setup(pianoMode: on, to: superView)
    }
    
    private func setup(pianoMode: Bool, to view: View) {
        
        changeStates(for: pianoMode)
        animate(for: pianoMode, to: view)
        setupPianoControl(pianoMode: pianoMode)
    }
    
    private func changeStates(for pianoMode: Bool) {
        
        isEditable = !pianoMode
        isSelectable = !pianoMode
        
    }
    
    internal func setupPianoControl(pianoMode: Bool) {
        
        if pianoMode {
            attachControl()
        } else {
            detachControl()
        }
    }
    
    private func animate(for pianoMode: Bool, to view: View) {
        
        view.constraints.forEach { (constraint) in
            if let identifier = constraint.identifier,
                identifier == ConstraintIdentifier.pianoTextViewTop {
                constraint.constant = pianoMode ? 100 : 0
                View.animate(withDuration: 0.3) {
                    view.layoutIfNeeded()
                }
                return
            }
        }
        
    }
    
    internal func attachControl() {
        
        guard let control = createSubviewIfNeeded(viewTag: ViewTag.PianoControl) as? PianoControl,
            let pianoView = superview?.createSubviewIfNeeded(viewTag: ViewTag.PianoView) as? PianoView else { return }
        control.removeFromSuperview()
        control.textAnimatable = pianoView
        control.pianoable = self
        let point = CGPoint(x: 0, y: contentOffset.y + contentInset.top)
        var size = bounds.size
        size.height -= (contentInset.top + contentInset.bottom)
        control.frame = CGRect(origin: point, size: size)
        addSubview(control)
        
    }
    
    internal func detachControl() {
        
        guard let control = subView(viewTag: ViewTag.PianoControl) as? PianoControl else { return }
        control.removeFromSuperview()
    }
    
    private func setNavigationController(pianoMode: Bool) {

        AppNavigator.currentNavigationController?.setNavigationBarHidden(pianoMode, animated: true)
        AppNavigator.currentViewController?.setToolbarItems(toolbarItems, animated: true)
        AppNavigator.currentNavigationController?.setToolbarHidden(!pianoMode, animated: true)
        
    }
}
