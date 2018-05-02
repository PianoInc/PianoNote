//
//  NoteSettingViewController.swift
//  PianoNote
//
//  Created by Kevin Kim on 04/04/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit
import RealmSwift

class NoteSettingViewController: UITableViewController {

    var noteID: String?
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        slider.value = Float(PianoNoteSizeInspector.shared.get().level)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }
    
    deinit {
        if let noteID = noteID {
            ModelManager.update(id: noteID, type: RealmNoteModel.self, kv: [Schema.Note.sizeLevel : PianoNoteSizeInspector.shared.get().level])
        }
    }

    @IBAction func valueChanged(_ sender: UISlider) {
        
        let sliderValue = lroundf(sender.value)
        if let newSize = PianoNoteSize(level: sliderValue),
            newSize != PianoNoteSizeInspector.shared.get() {
            
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            PianoNoteSizeInspector.shared.set(to: newSize)
        }
        
        sender.setValue(Float(sliderValue), animated: false)
        
    }

}
