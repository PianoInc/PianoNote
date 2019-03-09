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
        
        setupNavagationBarGray()
    }
    
    private func setupNavagationBarGray(){
//        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = UIColor.background.withAlphaComponent(0.95)
        
//        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .bottom)
        toolbar.backgroundColor = UIColor.background.withAlphaComponent(0.95)
    }
    
}

