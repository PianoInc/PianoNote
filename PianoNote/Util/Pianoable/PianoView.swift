//
//  PianoView.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class PianoView: UIView {

//    //MARK: Public
    public var attributes = PianoAttributes.foregroundColor
    
    internal var animatableTexts: [AnimatableText]? {
        didSet {
            if let animatableTexts = animatableTexts {
                attachLabels(for: animatableTexts)
                displayLink(on: true)
            } else {
                detachLabels(at: oldValue)
                currentFrame = 0
                totalFrame = 0
                progress = 0
                leftEndTouchX = nil
                rightEndTouchX = nil
                animating = false
            }
        }
    }
    
    private var totalFrame: Int = 0
    private var currentFrame: Int = 0
    private var progress: CGFloat = 0.0
    
    private var currentTouchX: CGFloat?
    private var leftEndTouchX: CGFloat?
    private var rightEndTouchX: CGFloat?
    internal var animating: Bool = false
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(PianoView.displayFrameTick))
        displayLink.add(
            to: RunLoop.current,
            forMode: RunLoopMode.commonModes)
        return displayLink
    }()

    @objc private func displayFrameTick() {
        if displayLink.duration > 0.0 && totalFrame == 0 {
            let frameRate = displayLink.duration
            totalFrame = Int(animationDuration / frameRate) + 1
        }
        currentFrame += 1
        if currentFrame <= totalFrame {
            progress += 1.0 / CGFloat(totalFrame)
            guard let touchX = currentTouchX else { return }
            updateLabels(to: touchX)
        } else {
            displayLink(on: false)
        }
    }
    
    internal func updateLabels(to touchX: CGFloat){
        
        guard let animatableTexts = animatableTexts else { return }
        backgroundColor = UIColor.white.withAlphaComponent(progress * 0.9)
        animatableTexts.enumerated().forEach { (index, animatableText) in
            applyAttrToLabel(index: index, animatableText: animatableText, at: touchX)
            moveLabel(index: index, animatableText: animatableText, at: touchX)
        }
        
    }

    internal func updateCoordinateXs(with pointX: CGFloat) {
        
        leftEndTouchX = leftEndTouchX ?? pointX
        rightEndTouchX = rightEndTouchX ?? pointX
        currentTouchX = pointX
        
        if pointX < leftEndTouchX!{
            leftEndTouchX = pointX
        }
        
        if pointX > rightEndTouchX! {
            rightEndTouchX = pointX
        }
    }
    
    private func moveLabel(index: Int, animatableText: AnimatableText, at touchX: CGFloat) {
        
        let distance = abs(touchX - animatableText.center.x)
        let rect = animatableText.rect
        let label = animatableText.label
        
        if distance < cosPeriod_half {
            let y = cosMaxHeight * (cos(CGFloat.pi * distance / cosPeriod_half ) + 1) * progress
            label.frame.origin.y = rect.origin.y - y
            
            if !(touchX > rect.origin.x && touchX < rect.origin.x + rect.width){
                //TODO: distance = 0일수록 알파값 0.3에 가까워지게 하기
                label.alpha = distance / cosPeriod_half + 0.3
            } else {
                label.alpha = 1
            }
        } else {
            //프레임 원위치로
            label.frame.origin = rect.origin
            //알파값 세팅
            label.alpha = 1
        }
        
    }

    private func applyAttrToLabel(index: Int, animatableText: AnimatableText, at touchX: CGFloat) {

        guard let operate = operate(index: index, animatableText: animatableText,at: touchX) else { return }
        
        switch operate {
        case .apply:
            animatableText.attrs = attributes.addAttribute(from: animatableText.attrs)
        case .remove:
            animatableText.attrs = attributes.removeAttribute(from: animatableText.attrs)
        case .none:
            ()
        }
        
        let attrText = NSAttributedString(string: animatableText.text, attributes: animatableText.attrs)
        animatableText.label.attributedText = attrText
        animatableText.label.sizeToFit()
        
    }
    
    enum AttributesOperate {
        case apply
        case remove
        case none
    }
    
    private func operate(index: Int, animatableText: AnimatableText, at touchX: CGFloat) -> AttributesOperate? {
        
        guard let leftEndTouchX = leftEndTouchX,
            let rightEndTouchX = rightEndTouchX else { return nil }

        let leftEdgeLabel = animatableText.rect.origin.x
        let rightEdgeLabel = leftEdgeLabel + animatableText.rect.width
        
        //TODO: 부등호 때문에 효과가 잘못 입혀지는거 의심되므로 체크, 딱 현재 포인트가 레이블 왼쪽, 오른쪽 끝에 오는경우 테스트
        let applyAttribute = touchX > rightEdgeLabel && leftEndTouchX < rightEdgeLabel
        let removeAttribute = touchX < leftEdgeLabel && rightEndTouchX > leftEdgeLabel
        
        if applyAttribute {
            return .apply
        } else if removeAttribute {
            return .remove
        } else {
            return .none
        }
        
    }

    private func displayLink(on: Bool) {
        displayLink.isPaused = !on
    }

    internal func animateToOriginalPosition(completion: @escaping CaptivateResult) {
        
        guard let animatableTexts = animatableTexts else { return }
        animating = true
        
        displayLink(on: false)

        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.backgroundColor = UIColor.white.withAlphaComponent(0)
            
            animatableTexts.forEach({ (animatableText) in
                animatableText.label.center = animatableText.center
                animatableText.label.alpha = 1
            })
            }, completion: { [weak self](_) in
                if let result = self?.pianoResults() {
                    //effectable에서 할 내용
                    completion(result)
                }
                //textAnimatable에서 할 내용
                self?.animatableTexts = nil
        })
    }
    
    private func pianoResults() -> [PianoResult]? {
        
        guard let animatableTexts = animatableTexts else { return nil }
        return animatableTexts.map{ PianoResult(range: $0.range, attrs: $0.attrs) }
        
    }

    private func attachLabels(for animatableTexts: [AnimatableText]){
        
        animatableTexts.forEach { (animatableText) in
            addSubview(animatableText.label)
        }
    
    }
    
    private func detachLabels(at oldAnimatableTexts: [AnimatableText]?) {
        
        oldAnimatableTexts?.forEach({ (animatableText) in
            animatableText.label.removeFromSuperview()
        })
        
    }
    
}

extension PianoView {
    
    private var cosPeriod_half: CGFloat { return 70 } //이거 Designable
    private var cosMaxHeight: CGFloat { return 35 }  //이것도 Designable
    private var animationDuration: Double { return 0.3 }
    
}
