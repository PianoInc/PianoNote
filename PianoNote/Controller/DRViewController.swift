//
//  DRViewController.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 6..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRViewController: UIViewController {
    
    private var titleAlpha: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navi(config: { navi, item in
            item.titleView?.alpha = titleAlpha
            item.titleView?.isHidden = (titleAlpha != 1)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navi(config: { navi, item in
            item.titleView?.alpha = titleAlpha
            item.titleView?.isHidden = false
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navi(config: { navi, item in
            titleAlpha = item.titleView?.alpha ?? 0
            item.titleView?.isHidden = (item.titleView?.alpha != 1)
        })
    }
    
}

