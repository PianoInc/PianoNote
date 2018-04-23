//
//  ViewController+Alert.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 4..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UIViewController {
    func alertWithErrorMessage(message: String, handler: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)

        let action = UIAlertAction(title: "확인", style: .default, handler: handler)
        alert.addAction(action)

        self.present(alert, animated: true)
    }

    func alertWithOKAction(message: String, handler: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        self.present(alert, animated: true)
    }

    func alertWithOKActionAndAlertHandler(message: String, alertHandler: @escaping (UIAlertController) -> ((UIAlertAction) -> ())) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)

        alert.addTextField()
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: alertHandler(alert))
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        self.present(alert, animated: true)
    }
}
