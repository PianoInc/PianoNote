//
//  PianoType.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

protocol PianoType {
    func setup(for pianoMode: Bool, to view: UIView)
}

extension PianoTextView: PianoType {
    func setup(for pianoMode: Bool, to view: UIView) {
        
        changeStates(for: pianoMode)
        animate(for: pianoMode)
        setupPianoControl(for: pianoMode, to: view)
        
    }
    
    internal func setupPianoControl(for pianoMode: Bool, to view: UIView) {
        
        guard let pianoControl = subView(tag: ViewTag.PianoControl) as? PianoControl,
            let pianoView = view.subView(tag: ViewTag.PianoView) as? PianoView else { return }
        if pianoMode {
            pianoControl.textAnimatable = pianoView
            pianoControl.effectable = self
            attach(control: pianoControl)
        } else {
            detach(control: pianoControl)
        }
    }
    
    private func attach(control: PianoControl) {
        control.removeFromSuperview()
        let point = CGPoint(x: 0, y: contentOffset.y + contentInset.top)
        var size = bounds.size
        size.height -= (contentInset.top + contentInset.bottom)
        control.frame = CGRect(origin: point, size: size)
        addSubview(control)
    }
    
    private func detach(control: PianoControl) {
        control.removeFromSuperview()
    }
    
    private func changeStates(for pianoMode: Bool) {
        
        isEditable = !pianoMode
        isSelectable = !pianoMode
        
    }
    
    private func animate(for pianoMode: Bool) {
        
        guard let superview = superview else { return }
        superview.constraints.forEach { (constraint) in
            if let identifier = constraint.identifier,
                identifier == ConstraintIdentifier.pianoTextViewTop {
                constraint.constant = pianoMode ? 100 : 0
                UIView.animate(withDuration: 0.3) {
                    superview.layoutIfNeeded()
                }
                return
            }
        }
        
    }
}

extension PianoView: PianoType {
    func setup(for pianoMode: Bool, to view: UIView) {
        
        if pianoMode {
            guard let pianoView = view.subView(tag: ViewTag.PianoView) as? PianoView else { return }
            view.addSubview(pianoView)
            pianoView.snp.makeConstraints({ (make) in
                make.top.bottom.equalTo(view)
                
                if #available(iOS 11.0, *) {
                    make.left.right.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.left.right.equalTo(view)
                }
            })
        } else {
            guard let pianoView = view.subView(tag: ViewTag.PianoView) as? PianoView else { return }
            pianoView.removeFromSuperview()
        }
        
    }
}

extension PianoSegmentControl: PianoType {
    func setup(for pianoMode: Bool, to view: UIView) {
        
        if pianoMode {
            guard let segmentControl = view.subView(tag: ViewTag.PianoSegmentControl) as? PianoSegmentControl,
                let pianoView = view.subView(tag: ViewTag.PianoView) as? PianoView,
                let textView = view.subView(tag: ViewTag.PianoTextView) as? PianoTextView else { return }
            view.insertSubview(segmentControl, belowSubview: textView)
            segmentControl.pianoView = pianoView
            segmentControl.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(view)
                make.height.equalTo(100)
            })
            
        } else {

            UIView.transition(with: view, duration: 0.33, options: [], animations: {
                guard let segmentControl = view.subView(tag: ViewTag.PianoSegmentControl) as? PianoSegmentControl else { return }
                segmentControl.removeFromSuperview()
            }, completion: nil)
        }
    }
}

extension PianoControl: PianoType {
    func setup(for pianoMode: Bool, to view: UIView) {

        if pianoMode {
            guard let controlView = view.subView(tag: ViewTag.PianoControl) as? PianoControl,
                let pianoView = view.subView(tag: ViewTag.PianoView) as? PianoView,
                let textView = view.subView(tag: ViewTag.PianoTextView) as? PianoTextView else { return }
            controlView.textAnimatable = pianoView
            controlView.effectable = textView
            controlView.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalTo(view)
            })
        }
    
    }
}




