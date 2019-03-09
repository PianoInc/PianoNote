//
//  PianoType.swift
//  PianoNote
//
//  Created by Kevin Kim on 26/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

protocol PianoSetup {
    func setup(pianoMode: Bool, to view: UIView)
}

extension PianoView: PianoSetup {
    func setup(pianoMode: Bool, to view: UIView) {
        
        if pianoMode {
            guard let pianoView = view.createSubviewIfNeeded(viewTag: ViewTag.PianoView) as? PianoView else { return }
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
            guard let pianoView = view.subView(viewTag: ViewTag.PianoView) as? PianoView else { return }
            pianoView.removeFromSuperview()
        }
        
    }
}

extension PianoSegmentControl: PianoSetup {
    func setup(pianoMode: Bool, to view: UIView) {
        
        if pianoMode {
            guard let segmentControl = view.createSubviewIfNeeded(viewTag: ViewTag.PianoSegmentControl) as? PianoSegmentControl,
                let pianoView = view.createSubviewIfNeeded(viewTag: ViewTag.PianoView) as? PianoView,
                let textView = view.createSubviewIfNeeded(viewTag: ViewTag.PianoTextView) as? PianoTextView else { return }
            view.insertSubview(segmentControl, belowSubview: textView)
            segmentControl.pianoView = pianoView
            segmentControl.snp.makeConstraints({ (make) in
                make.top.equalTo(view).labeled(ConstraintIdentifier.pianoSegmentControlTop)
                make.left.right.equalTo(view)
                make.height.equalTo(100)
            })
            
        } else {
            guard let segmentControl = view.subView(viewTag: ViewTag.PianoSegmentControl) as? PianoSegmentControl else { return }
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
    func setup(pianoMode: Bool, to view: UIView) {

        if pianoMode {
            guard let controlView = view.createSubviewIfNeeded(viewTag: ViewTag.PianoControl) as? PianoControl,
                let pianoView = view.createSubviewIfNeeded(viewTag: ViewTag.PianoView) as? PianoView,
                let textView = view.createSubviewIfNeeded(viewTag: ViewTag.PianoTextView) as? PianoTextView else { return }
            controlView.textAnimatable = pianoView
            controlView.pianoable = textView
            controlView.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalTo(view)
            })
        }
    
    }
}




