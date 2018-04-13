//
//  NoteViewController.swift
//  PianoNote
//
//  Created by Kevin Kim on 23/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

class NoteViewController: UIViewController {

    @IBOutlet weak var textView: PianoTextView!
    var invokingTextViewDelegate: Bool = false
    var noteID: String?
    var isSaving: Bool = false
    var initialImageRecordNames: Set<String>!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        textView.textStorage.delegate = self
        
        if #available(iOS 11.0, *) {
            textView.textDragDelegate = self
            textView.textDropDelegate = self
            textView.pasteDelegate = self
        }
        
        textView.interactiveDelegate = self
        textView.interactiveDataSource = self
        //register xibs
        //synchronizers
        
        setNavigationItemsForDefault()
        setCanvasSize(view.bounds.size)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        
        do {
            let realm = try Realm()
            guard let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
            let attributes = try JSONDecoder().decode([PianoAttribute].self, from: note.attributes)
            
            textView.set(string: note.content, with: attributes)
            
            let imageRecordNames = attributes.compactMap { attribute -> String? in
                if case let .attachment(.image(imageAttribute)) = attribute.style {return imageAttribute.id}
                else {return nil}
                }
            
            initialImageRecordNames = Set<String>(imageRecordNames)
            
        } catch {print(error)}
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
    
    private func subscribeToChange() {
        textView.rx.text.asObservable()
            .map{_ -> Void in return}.throttle(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.saveText()
            }).disposed(by: disposeBag)
    }
    
    func saveText() {
        DispatchQueue.main.async {
            if self.isSaving || self.textView.isSyncing {
                return
            }
            self.isSaving = true
            let (string, attributes) = self.textView.get()
            DispatchQueue.global().async {
                let jsonEncoder = JSONEncoder()
                guard let data = try? jsonEncoder.encode(attributes),
                    let noteID = self.noteID else {return}
                let kv: [String: Any] = ["content": string, "attributes": data]
                
                ModelManager.update(id: noteID, type: RealmNoteModel.self, kv: kv) { [weak self] error in
                    if let error = error {print(error)}
                    else {print("happy")}
                    self?.isSaving = false
                }
            }
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

