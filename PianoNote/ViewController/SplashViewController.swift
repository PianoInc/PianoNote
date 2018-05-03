//
//  SplashViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class SplashViewController: DRViewController {
    
    let debug = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButton()
    }
    
    private func initButton() {
        guard debug else {return}
        func present(viewCtrl: UIViewController) {
            UIView.transition(with: navigationController!.view,
                              duration: 0.5,
                              options: [.transitionCrossDissolve],
                              animations: {self.present(view: viewCtrl, animated: false)})
        }
        
        let list = ["FolderViewController", "RecycleViewController",
                    "FacebookViewController", "InfoViewController"]
        let offsetY = safeInset.top + naviHeight
        let width = mainSize.width - safeInset.left - safeInset.right
        let height = 80.fit
        
        list.enumerated().forEach { idx, data in
            let button = UIButton()
            button.frame = CGRect(x: 0, y: height * CGFloat(idx) + offsetY, width: width, height: height)
            button.border(color: .black, width: 0.5)
            button.setTitle(data, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            view.addSubview(button)
            _ = button.rx.tap.subscribe { _ in present(viewCtrl: UIStoryboard.view(id: data))}
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !debug else {return}
        UIView.transition(with: navigationController!.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.present(id: "MainListViewController", animated: false)
        })
    }
    
}

