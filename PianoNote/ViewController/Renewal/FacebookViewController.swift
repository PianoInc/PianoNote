//
//  FacebookViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 5. 1..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class FacebookViewController: DRViewController {
    
    private let nodeCtrl = FacebookNodeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubnode(nodeCtrl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nodeCtrl.frame = view.frame
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        DRFBService.share.resetPost()
    }
    
}

class FacebookNodeController: ASDisplayNode {
    
    override init() {
        super.init()
    }
    
}

