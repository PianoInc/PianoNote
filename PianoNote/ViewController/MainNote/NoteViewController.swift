//
//  NoteViewController.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var textView: PianoTextView!
    var invokingTextViewDelegate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.textStorage.delegate = self
        setNavigationItemsForDefault()
        setCanvasSize(view.bounds.size)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        
    }
    
    private func setCanvasSize(_ size: CGSize) {
        
        if size.width > size.height {
            textView.textContainerInset.left = size.width / 10
            textView.textContainerInset.right = size.width / 10
        } else {
            textView.textContainerInset.left = 0
            textView.textContainerInset.right = 0
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        registerKeyboardNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unRegisterKeyboardNotification()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setCanvasSize(size)
        
        coordinator.animate(alongsideTransition: nil) {[weak self] (_) in
            guard let strongSelf = self else { return }
            
            if !strongSelf.textView.isEditable {
                strongSelf.textView.attachControl()
                
                
            }
        }
    }
    
}

extension NoteViewController {
    internal func setup(pianoMode: Bool) {
        
        setNavigationController(for: pianoMode)
        
        guard let pianoView = view.subView(tag: ViewTag.PianoView) as? PianoView,
            let segmentControl = view.subView(tag: ViewTag.PianoSegmentControl) as? PianoSegmentControl else { return }
        
        pianoView.setup(for: pianoMode, to: view)
        segmentControl.setup(for: pianoMode, to: view)
        textView.setup(for: pianoMode, to: view)
        
    }
    
}

