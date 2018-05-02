//
//  SplashViewController.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class SplashViewController: DRViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let originY = safeInset.top + naviHeight
        let width = mainSize.width / 3
        let height = mainSize.height - safeInset.top - safeInset.bottom - naviHeight
        
        let button1 = UIButton()
        button1.frame = CGRect(x: 0, y: originY, width: width, height: height)
        button1.backgroundColor = .red
        button1.setTitle("Folder", for: .normal)
        button1.setTitleColor(.black, for: .normal)
        button1.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        view.addSubview(button1)
        _ = button1.rx.tap.subscribe { _ in
            self.present(viewCtrl: UIStoryboard.view(type: FolderViewController.self))
        }
        let button2 = UIButton()
        button2.frame = CGRect(x: width, y: originY, width: width, height: height)
        button2.backgroundColor = .blue
        button2.setTitle("Recycle", for: .normal)
        button2.setTitleColor(.black, for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        view.addSubview(button2)
        _ = button2.rx.tap.subscribe { _ in
            self.present(viewCtrl: UIStoryboard.view(type: RecycleViewController.self))
        }
        let button3 = UIButton()
        button3.frame = CGRect(x: width * 2, y: originY, width: width, height: height)
        button3.backgroundColor = .green
        button3.setTitle("Fb", for: .normal)
        button3.setTitleColor(.black, for: .normal)
        button3.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        view.addSubview(button3)
        _ = button3.rx.tap.subscribe { _ in
            self.present(viewCtrl: UIStoryboard.view(type: FacebookViewController.self))
        }
    }
    
    private func present(viewCtrl: UIViewController) {
        UIView.transition(with: navigationController!.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.present(view: viewCtrl, animated: false)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.transition(with: navigationController!.view, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            //self.present(id: "MainListViewController", animated: false)
        })
    }
    
}

