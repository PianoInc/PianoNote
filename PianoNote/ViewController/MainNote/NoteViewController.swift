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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        registerKeyboardNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unRegisterKeyboardNotification()
        
    }
    
    @IBAction func tap(_ sender: Any) {
        
        setup(pianoMode: true)
        
    }
    
    @objc func tapDone(sender: Any) {
        
        setup(pianoMode: false)
        
    }
    
    @objc func tapInfo(sender: Any) {
        
    }
    
}

extension NoteViewController {
    private func setup(pianoMode: Bool) {
        
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
            action: #selector(tapDone(sender:)))
        let info = UIBarButtonItem(
            image: UIImage(named: "info"),
            style: .plain,
            target: self,
            action: #selector(tapInfo(sender:)))
        
        self.setToolbarItems([flexibleSpace, done, flexibleSpace, info], animated: true)
        navigationController?.setToolbarHidden(!pianoMode, animated: true)
        
    }
    
}

