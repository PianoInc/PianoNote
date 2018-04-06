//
//  PianoType.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

protocol PianoSetup {
    func setup(for pianoMode: Bool, to view: UIView)
}

extension PianoTextView: PianoSetup {
    func setup(for pianoMode: Bool, to view: UIView) {
        
        changeStates(for: pianoMode)
        animate(for: pianoMode, to: view)
        setupPianoControl(for: pianoMode)
        
    }
    
    internal func setupPianoControl(for pianoMode: Bool) {
        
        if pianoMode {
            attachControl()
        } else {
            detachControl()
        }
    }
    
    internal func attachControl() {
        
        guard let control = subView(tag: ViewTag.PianoControl) as? PianoControl,
            let pianoView = superview?.subView(tag: ViewTag.PianoView) as? PianoView else { return }
        control.removeFromSuperview()
        control.textAnimatable = pianoView
        control.effectable = self
        let point = CGPoint(x: 0, y: contentOffset.y + contentInset.top)
        var size = bounds.size
        size.height -= (contentInset.top + contentInset.bottom)
        control.frame = CGRect(origin: point, size: size)
        addSubview(control)
        
    }
    
    internal func detachControl() {
        
        guard let control = subView(tag: ViewTag.PianoControl) as? PianoControl else { return }
        control.removeFromSuperview()
    }
    
    private func changeStates(for pianoMode: Bool) {
        
        isEditable = !pianoMode
        isSelectable = !pianoMode
        
    }
    
    private func animate(for pianoMode: Bool, to view: UIView) {
        
        view.constraints.forEach { (constraint) in
            if let identifier = constraint.identifier,
                identifier == ConstraintIdentifier.pianoTextViewTop {
                constraint.constant = pianoMode ? 100 : 0
                UIView.animate(withDuration: 0.3) {
                    view.layoutIfNeeded()
                }
                return
            }
        }
        
    }
}

extension PianoView: PianoSetup {
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

extension PianoSegmentControl: PianoSetup {
    func setup(for pianoMode: Bool, to view: UIView) {
        
        if pianoMode {
            guard let segmentControl = view.subView(tag: ViewTag.PianoSegmentControl) as? PianoSegmentControl,
                let pianoView = view.subView(tag: ViewTag.PianoView) as? PianoView,
                let textView = view.subView(tag: ViewTag.PianoTextView) as? PianoTextView else { return }
            view.insertSubview(segmentControl, belowSubview: textView)
            segmentControl.pianoView = pianoView
            segmentControl.snp.makeConstraints({ (make) in
                make.top.equalTo(view).labeled(ConstraintIdentifier.pianoSegmentControlTop)
                make.left.right.equalTo(view)
                make.height.equalTo(100)
            })
            
        } else {
            guard let segmentControl = view.subView(tag: ViewTag.PianoSegmentControl) as? PianoSegmentControl else { return }
            UIView.animate(withDuration: 0.33, animations: {
                view.constraints.forEach { (constraint) in
                    if let identifier = constraint.identifier,
                        identifier == ConstraintIdentifier.pianoSegmentControlTop {
                        constraint.constant = pianoMode ? 0 : -100
                        view.layoutIfNeeded()
                        return
                    }
                }
            }, completion: { (bool) in
                if bool {
                    segmentControl.removeFromSuperview()
                }
            })
        }
    }
}

extension PianoControl: PianoSetup {
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




