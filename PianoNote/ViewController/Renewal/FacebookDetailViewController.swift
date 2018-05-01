//
//  FacebookDetailViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 1..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FacebookDetailViewController: DRViewController {
    
    private let nodeCtrl = FacebookDetailNodeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubnode(nodeCtrl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nodeCtrl.frame = view.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(hex6: "EAEBED")
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        navigationController?.navigationBar.barTintColor = UIColor(hex6: "F9F9F9")
        DRFBService.share.resetComment()
    }
    
}

class FacebookDetailNodeController: ASDisplayNode {
    
    override init() {
        super.init()
    }
    
}

