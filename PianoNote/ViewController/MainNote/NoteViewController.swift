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
    
    private func setNavigationController(for pianoMode: Bool) {
        
        navigationController?.setNavigationBarHidden(pianoMode, animated: true)
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil)
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(tapPianoDone(sender:)))
        let info = UIBarButtonItem(
            image: UIImage(named: "info"),
            style: .plain,
            target: self,
            action: #selector(tapPianoInfo(sender:)))
        
        self.setToolbarItems([flexibleSpace, done, flexibleSpace, info], animated: true)
        navigationController?.setToolbarHidden(!pianoMode, animated: true)
        
    }
    
    @objc func tapPianoDone(sender: Any) {
        setup(pianoMode: false)
    }
    
    @objc func tapPianoInfo(sender: Any) {
        
    }
    
}

