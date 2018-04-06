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

    open func register(nib: UINib?, forCellReuseIdentifier identifier: String) {
        dispatcher.register(nib: nib, forCellReuseIdentifier: identifier)
    }
    open func dequeueReusableCell(withIdentifier identifier: String) -> InteractiveAttachmentCell {
        return dispatcher.dequeueReusableCell(withIdentifier: identifier)
    }

    @objc func animateLayers(displayLink: CADisplayLink) {
        guard let layers = self.layer.sublayers else {return}
        layers.compactMap{ $0 as? InteractiveBackgroundLayer }.forEach {
            guard let cgColor = $0.backgroundColor else {return}
            let newColor = UIColor(cgColor: cgColor).withAlphaComponent(cgColor.alpha - 0.03)

            $0.backgroundColor = newColor.cgColor
            if $0.backgroundColor?.alpha == 0 {
                $0.removeFromSuperlayer()
                let glyphRange = self.layoutManager.glyphRange(forBoundingRect: $0.frame, in: self.textContainer)
                let characterRange = self.layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
                textStorage.removeAttribute(.animatingBackground, range: characterRange)
            }
        }
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
