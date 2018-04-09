//
//  DRClearNavigationController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 26..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRClearNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation의 구분선을 없앤다.
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
    }
    
}

