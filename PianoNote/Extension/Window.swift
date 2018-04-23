//
//  Window.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/// 최대 제한 width 값.
let limitWidth: CGFloat = 812

extension UIWindow {
    
    /// 호출하는 순간의 최상위 ViewController를 반환한다.
    static var topVC: UIViewController? {
        return topVC()
    }
    
    /**
     호출하는 순간의 최상위 ViewController를 산출한다.
     - parameter controller : rootViewController (default)
     */
    private static func topVC(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let tabBarView = controller as? UITabBarController {
            return topVC(controller: tabBarView.selectedViewController)
        } else if let navigation = controller as? UINavigationController {
            return topVC(controller: navigation.visibleViewController)
        } else if let presentedView = controller?.presentedViewController {
            return topVC(controller: presentedView)
        } else {
            return controller
        }
    }
    
}

