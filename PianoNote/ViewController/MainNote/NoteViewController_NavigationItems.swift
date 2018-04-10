//
//  NoteNavigationItems.swift
//  PianoNote
//
//  Created by Kevin Kim on 29/03/2018.
//  Copyright © 2018 piano. All rights reserved.
//

import UIKit

extension NoteViewController {
    
    internal func setNavigationItemsForTyping() {
        
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(tapDone(sender:)))
        let copyAll = UIBarButtonItem(
            title: "전체복사",
            style: .plain,
            target: self,
            action: #selector(tapCopyAll(sender:)))
        let align = UIBarButtonItem(
            image: UIImage(named: "alignment"),
            style: .plain,
            target: self,
            action: #selector(tapAlignment(sender:)))
        
        navigationItem.setRightBarButtonItems(
            [done, copyAll, align],
            animated: true)
        
    }
    
    internal func setNavigationItemsForDefault() {
        
        let setting = UIBarButtonItem(
            image: UIImage(named: "setting"),
            style: .plain,
            target: self,
            action: #selector(tapSetting(sender:)))
        let addPeople = UIBarButtonItem(
            image: UIImage(named: "addPeople"),
            style: .plain,
            target: self,
            action: #selector(tapAddPeople(sender:)))
        let piano = UIBarButtonItem(
            image: UIImage(named: "piano"),
            style: .plain,
            target: self,
            action: #selector(tapPiano(sender:)))
        
        navigationItem.setRightBarButtonItems(
            [setting,
             addPeople,
             piano],
            animated: true)
        
    }
    
    @objc func tapAlignment(sender: UIBarButtonItem) {
        //이미지를 identifier로 하고, 이미지에 따라서 텍스트뷰의 alignment를 바꿔줌.
      
    }
    
    @objc func tapCopyAll(sender: Any) {
        //statusBar에 전체 복사 완료되었다는 뷰를 애니메이션시켜서 보여준다
    }
    
    @objc func tapDone(sender: Any) {
        textView.resignFirstResponder()
    }
    
    @objc func tapPiano(sender: Any) {
        setup(pianoMode: true)
    }
    
    @objc func tapAddPeople(sender: UIBarButtonItem) {
        
    }
    
    @objc func tapSetting(sender: Any) {
        performSegue(withIdentifier: SegueIdentifer.NoteSettingViewController, sender: textView)
    }
    
    
    internal func setNavigationController(for pianoMode: Bool) {
        
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
