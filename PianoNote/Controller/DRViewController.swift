//
//  DRViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 6..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRViewController: UIViewController {
    
    /// ViewController간의 화면 전환시 navigation의 titleView가 자연스럽게 보일 수 있도록 alpha을 저장해둔다.
    private var titleViewAlpha: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navi { (_, item) in
            item.titleView?.alpha = titleViewAlpha
            item.titleView?.isHidden = (titleViewAlpha != 1)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navi { (_, item) in
            item.titleView?.alpha = titleViewAlpha
            item.titleView?.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navi { (_, item) in
            titleViewAlpha = item.titleView?.alpha ?? 0
            item.titleView?.isHidden = (item.titleView?.alpha != 1)
        }
    }
    
    deinit {
        NSLog("deinit... %@", self)
    }
    
}

