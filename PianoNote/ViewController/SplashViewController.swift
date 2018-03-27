//
//  SplashViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.transition(with: navigationController!.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.present(id: "MainListViewController", animated: false)
        })
    }
    
}

