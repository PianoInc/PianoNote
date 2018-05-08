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
        // Navigation의 배경을 없앤다.
        //navigationBar.setBackgroundImage(UIImage(), for: .default)
        //toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        
        // Navigation의 구분선을 없앤다.
        navigationBar.shadowImage = UIImage()
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
}

