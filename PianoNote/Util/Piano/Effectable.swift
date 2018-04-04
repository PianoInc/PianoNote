//
//  Effectable.swift
//  PianoNote
//
//  Created by Kevin Kim on 24/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

protocol Effectable: class {
    
    func preparePiano(at touch: UITouch) -> AnimatableTextsTrigger
    func endPiano(with result: [PianoResult])
}

extension PianoTextView: Effectable {
    
    func preparePiano(at touch: UITouch) -> AnimatableTextsTrigger {
        
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
        let point = touch.location(in: self)
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
                let label = UILabel(frame: CGRect(origin: origin, size: CGSize.zero))
                label.attributedText = attrText
                label.sizeToFit()

                return AnimatableText(label: label, range: range, rect: label.frame, center: label.center, text: text, attrs: attrs)
                
        })
        
    }
    
    internal func addCoverView(rect: CGRect) {
        var correctRect = rect
        correctRect.origin.y += textContainerInset.top
        let coverView = subView(tag: ViewTag.PianoCoverView)
        let control = subView(tag: ViewTag.PianoControl)
        coverView.backgroundColor = self.backgroundColor
        coverView.frame = correctRect
        insertSubview(coverView, belowSubview: control)

    }
    
    internal func removeCoverView(){
        
        let coverView = subView(tag: ViewTag.PianoCoverView)
        coverView.removeFromSuperview()
        
    }
}
