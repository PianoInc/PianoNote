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
import CloudKit

class NoteViewController: UIViewController {

    @IBOutlet weak var textView: PianoTextView!
    var invokingTextViewDelegate: Bool = false
    var noteID: String!
    var isSaving: Bool = false
    var initialImageRecordNames: Set<String> = []
    let disposeBag = DisposeBag()
    var synchronizer: NoteSynchronizer!
    var notificationToken: NotificationToken?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let realm = try? Realm(),
            let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) {
            if let size = PianoNoteSize(level: note.sizeLevel) {
                PianoNoteSizeInspector.shared.set(to: size)
            }
            //TODO: set colors
        }
        setDelegates()
        registerNibs()

        textView.noteID = noteID
        textView.typingAttributes = FormAttributes.defaultTypingAttributes
        synchronizer = NoteSynchronizer(textView: textView)
        synchronizer?.registerToCloud()
        
        setNavigationItemsForDefault()
        setCanvasSize(view.bounds.size)
        
        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        navigationController?.navigationBar.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        setNoteContents()
        subscribeToChange()
    }
    
    deinit {
        synchronizer?.unregisterFromCloud()
        notificationToken?.invalidate()
        removeGarbageImages()
        
        let (string,pianoAttribute) = textView.get()
        
        guard let realm = try? Realm(),
            let noteModel = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID),
            let jsonData = try? JSONEncoder().encode(pianoAttribute) else {return}
        
        if noteModel.content != string || noteModel.attributes != jsonData {
            saveText(isDeallocating: true)
        }
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
    
    private func setDelegates() {
        textView.delegate = self
        textView.textStorage.delegate = self
        
        if #available(iOS 11.0, *) {
            textView.textDragDelegate = self
            textView.textDropDelegate = self
            textView.pasteDelegate = self
        }
        
        textView.interactiveDelegate = self
        textView.interactiveDataSource = self
    }
    
    private func subscribeToChange() {
        textView.rx.attributedText.asObservable().distinctUntilChanged()
            .skip(1)
            .map{_ -> Void in return}.debounce(2.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    self?.saveText(isDeallocating: false)
                }
            }).disposed(by: disposeBag)

        if let realm = try? Realm(),
                let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) {
            notificationToken = note.observe { [weak self] change in
                switch change {
                    case .change(let properties):
                        if let newBackground = (properties.filter{ $0.name == Schema.Note.backgroundColorString }).first?.newValue as? String {
                            let color = Color(hex6: newBackground)
                            //TODO: set Color
                        }

                        if let newSizeLevel = (properties.filter { $0.name == Schema.Note.sizeLevel}).first?.newValue as? Int,
                            let newSize = PianoNoteSize(level: newSizeLevel) {
                            PianoNoteSizeInspector.shared.set(to: newSize)
                            DispatchQueue.main.async {
                                self?.resetFonts()
                            }
                        }
                    default: break
                }
            }
        }
    }

    private func resetFonts() {
        self.textView.textStorage.enumerateAttribute(.pianoFontInfo, in: NSMakeRange(0, textView.textStorage.length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
            guard let fontAttribute = value as? PianoFontAttribute else {return}
            let font = fontAttribute.getFont()
            textView.textStorage.addAttribute(.font, value: font, range: range)
        }
    }

    private func registerNibs() {

        textView.register(nib: UINib(nibName: "PianoTextImageCell", bundle: nil), forCellReuseIdentifier: ImageAttachment.cellIdentifier)
        textView.register(nib: UINib(nibName: "PianoTextLinkCell", bundle: nil), forCellReuseIdentifier: LinkAttachment.cellIdentifier)
        textView.register(nib: UINib(nibName: "PianoTextAddressCell", bundle: nil), forCellReuseIdentifier: AddressAttachment.cellIdentifier)
        textView.register(nib: UINib(nibName: "PianoTextContactCell", bundle: nil), forCellReuseIdentifier: ContactAttachment.cellIdentifier)
        textView.register(nib: UINib(nibName: "PianoTextEventCell", bundle: nil), forCellReuseIdentifier: EventAttachment.cellIdentifier)
        textView.register(nib: UINib(nibName: "PianoTextReminderCell", bundle: nil), forCellReuseIdentifier: ReminderAttachment.cellIdentifier)
        
    }
    
    private func setNoteContents() {
        do {
            let realm = try Realm()
            guard let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
            let attributes = try JSONDecoder().decode([AttributeModel].self, from: note.attributes)
            
            textView.set(string: note.content, with: attributes)
            
            let imageRecordNames = attributes.compactMap { attribute -> String? in
                if case let .attachment(.image(imageAttribute)) = attribute.style {return imageAttribute.id}
                else {return nil}
            }
            
            initialImageRecordNames = Set<String>(imageRecordNames)
            
        } catch {print(error)}
    }
    
    private func removeGarbageImages() {
        guard let realm = try? Realm(),
            let noteID = noteID,
            let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        //get zoneID from record
        let coder = NSKeyedUnarchiver(forReadingWith: note.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data polluted!!")}
        coder.finishDecoding()

        let (_, attributes) = textView.attributedText.getStringWithPianoAttributes()
        
        let imageRecordNames = attributes.map { attribute -> String in
            if case let .attachment(.image(imageAttribute)) = attribute.style {return imageAttribute.id}
            else {return ""}
            }.filter{!$0.isEmpty}
        
        let currentImageRecordNames = Set<String>(imageRecordNames)
        initialImageRecordNames.subtract(currentImageRecordNames)
        
        let deletedImageRecordIDs = Array<String>(initialImageRecordNames).map{ CKRecordID(recordName: $0, zoneID: record.recordID.zoneID)}

        if note.isShared {
            CloudManager.shared.sharedDatabase.delete(recordIDs: deletedImageRecordIDs) { error in
                guard error == nil else { return }
            }
        } else {
            CloudManager.shared.privateDatabase.delete(recordIDs: deletedImageRecordIDs) { error in
                guard error == nil else { return print(error!) }
            }
        }
    }
    
    func saveText(isDeallocating: Bool) {
        if self.isSaving || self.textView.isSyncing {
            return
        }
        let (string, attributes) = self.textView.get()
        let noteID = self.noteID ?? ""
        self.isSaving = true
        
        DispatchQueue.global().async {
            let jsonEncoder = JSONEncoder()
            guard let data = try? jsonEncoder.encode(attributes) else {self.isSaving = false;return}
            let kv: [String: Any] = ["content": string, "attributes": data]
            
            let completion: ((Error?) -> Void)? = isDeallocating ? nil : { [weak self] error in
                if let error = error {print(error)}
                else {print("happy")}
                self?.isSaving = false
            }
            
            ModelManager.update(id: noteID, type: RealmNoteModel.self, kv: kv, completion: completion)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "NoteSettingViewController" {
            guard let destVC = segue.destination as? NoteSettingViewController else {return}
            destVC.noteID = noteID
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

