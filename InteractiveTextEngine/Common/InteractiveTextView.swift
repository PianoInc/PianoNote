//
//  InteractiveTextView.swift
//  InteractiveTextEngine
//
//  Created by 김범수 on 2018. 3. 22..
//

import Foundation

extension InteractiveTextView {

    func add(_ attachment: InteractiveTextAttachment) {
        dispatcher.add(attachment: attachment)
    }

    func remove(attachmentID: String) {
        dispatcher.remove(attachmentID: attachmentID)
    }
    
    public func reload(attachmentID: String) {
        dispatcher.reload(attachmentID: attachmentID)
    }
    
    public func startDisplayLink() {
        displayLink?.isPaused = false
        //백그라운드들을 저장!
        animationLayer?.fillColor = UIColor.orange.cgColor
    }

    open func register(nib: UINib?, forCellReuseIdentifier identifier: String) {
        dispatcher.register(nib: nib, forCellReuseIdentifier: identifier)
    }
    open func dequeueReusableCell(withIdentifier identifier: String) -> InteractiveAttachmentCell {
        return dispatcher.dequeueReusableCell(withIdentifier: identifier)
    }

    @objc func animateLayers(displayLink: CADisplayLink) {

        var ranges:[NSRange] = []
//        print("hiiiiiiiiiiiii")
        
        textStorage.enumerateAttribute(.animatingBackground, in: NSMakeRange(0, textStorage.length), options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            guard let _ = value as? Bool else {return}
            ranges.append(range)
        }
        
        let path = UIBezierPath()
        ranges.forEach {
            let currentGlyphRange = layoutManager.glyphRange(forCharacterRange: $0, actualCharacterRange: nil)
            let firstLocation = layoutManager.location(forGlyphAt: currentGlyphRange.lowerBound)
            let firstLineFragment = layoutManager.lineFragmentRect(forGlyphAt: currentGlyphRange.lowerBound, effectiveRange: nil)
            let lastLocation = layoutManager.location(forGlyphAt: currentGlyphRange.upperBound)
            
            let lastLineFragment = layoutManager.lineFragmentRect(forGlyphAt: currentGlyphRange.upperBound-1, effectiveRange: nil)
            let trimmedFirst = CGRect(origin: CGPoint(x: firstLocation.x, y: firstLineFragment.minY),
                                      size: CGSize(width: bounds.width - firstLocation.x - textContainerInset.right - textContainerInset.left, height: firstLineFragment.height))
            let trimmedLast = CGRect(origin: CGPoint(x: textContainerInset.left, y: lastLineFragment.minY),
                                     size: CGSize(width: lastLocation.x - textContainerInset.left, height: lastLineFragment.height))
            
            if firstLineFragment == lastLineFragment {
                let block = trimmedFirst.intersection(trimmedLast).offsetBy(dx: 0, dy: textContainerInset.top)
                if block.isValid {
                    path.append(UIBezierPath(rect: block))
                    print(block)
                }
            } else {
                let middleRect = CGRect(origin: CGPoint(x: textContainerInset.left, y: firstLineFragment.maxY),
                                        size: CGSize(width: trimmedFirst.maxX - trimmedLast.minX,
                                                     height: lastLineFragment.minY - firstLineFragment.maxY))
                if trimmedFirst.isValid {
                    path.append(UIBezierPath(rect: trimmedFirst.offsetBy(dx: 0, dy: textContainerInset.top)))
                }
                if middleRect.isValid {
                    path.append(UIBezierPath(rect: middleRect.offsetBy(dx: 0, dy: textContainerInset.top)))
                }
                if trimmedLast.isValid {
                    path.append(UIBezierPath(rect: trimmedLast.offsetBy(dx: 0, dy: textContainerInset.top)))
                }
                print(middleRect)
            }
        }
        let alpha = animationLayer?.fillColor?.alpha
        if let alpha = alpha {
            if alpha <= 0 {
                displayLink.isPaused = true
                textStorage.removeAttribute(.animatingBackground, range: NSMakeRange(0, textStorage.length))
            }
            animationLayer?.fillColor = UIColor.orange.withAlphaComponent(alpha - 0.01).cgColor
        }
        animationLayer?.path = path.cgPath
        animationLayer?.fillRule = kCAFillRuleNonZero
        
        
    }

    func validateDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(animateLayers(displayLink:)))
        displayLink?.preferredFramesPerSecond = 20
        displayLink?.isPaused = true
        displayLink?.add(to: .main, forMode: .defaultRunLoopMode)
    }

}

public protocol InteractiveTextViewDataSource: AnyObject {
    func textView(_ textView: InteractiveTextView, attachmentForCell attachment: InteractiveTextAttachment) -> InteractiveAttachmentCell
}

@objc public protocol InteractiveTextViewDelegate: AnyObject {
    @objc optional func textView(_ textView: InteractiveTextView, willDisplay: InteractiveAttachmentCell)
    @objc optional func textView(_ textView: InteractiveTextView, didDisplay: InteractiveAttachmentCell)
    @objc optional func textView(_ textView: InteractiveTextView, willEndDisplaying: InteractiveAttachmentCell)
    @objc optional func textView(_ textView: InteractiveTextView, didEndDisplaying: InteractiveAttachmentCell)
}

extension CGRect {
    var isValid: Bool {
        return !isNull && !isInfinite && !isEmpty
    }
}
