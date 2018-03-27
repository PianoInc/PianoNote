//
//  View.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import SnapKit

/**
 View 생성 helper.
 - parameter view : 생성하고자 하는 view.
 - parameter attr : View에 대한 attribute 선언부.
 - returns : Attribute가 설정된 view.
 */
func makeView<T>(_ view: T, _ attr: ((T) -> ())) -> T {
    attr(view)
    return view
}

/**
 Constraints 정의 helper.
 - parameter view : Constraints를 정의하려는 view.
 - parameter const : View에 대한 constraints 선언부.
 - returns : Constraints가 설정된 view.
 */
func makeConst<T>(_ view: T, _ const: @escaping ((ConstraintMaker) -> ())) where T: UIView {
    view.snp.removeConstraints()
    view.snp.makeConstraints {const($0)}
    view.setNeedsLayout()
}

extension UIViewController {
    
    /**
     주어진 identifier를 통해 pushViewController를 진행한다.
     - parameter id : UIViewController Identifier.
     */
    func present(id: String) {
        if let navigation = navigationController {
            navigation.pushViewController(UIStoryboard.view(id: id), animated: true)
        }
    }
    
    /**
     주어진 viewController를 통해 pushViewController를 진행한다.
     - parameter view : UIViewController self.
     */
    func present(view: UIViewController) {
        if let navigation = navigationController {
            navigation.pushViewController(view, animated: true)
        }
    }
    
    /// 이전 viewController로 dismiss를 진행한다.
    func dismiss() {
        if let navigation = navigationController {
            navigation.popViewController(animated: true)
        }
    }
    
    /**
     주어진 identifier를 통해 popToViewController를 진행한다.
     - parameter id : UIViewController Identifier.
     */
    func dismiss(to id: String) {
        if let navigation = navigationController, let target = navigation.viewControllers.first(where: {String(describing: type(of: $0)) == id}) {
            navigation.popToViewController(target, animated: true)
        }
    }
    
    /**
     주어진 viewController를 통해 pushViewController를 진행한다.
     - parameter view : UIViewController self.
     */
    func dismiss(to view: UIViewController) {
        if let navigation = navigationController, let target = navigation.viewControllers.first(where: {$0 == view}) {
            navigation.popToViewController(target, animated: true)
        }
    }
    
}

extension UIStoryboard {
    
    /**
     Storyboard 주어진 generic type과 동일한 id를 가지는 viewController를 반환한다.
     - parameter type : UIViewController type.
     - parameter board : UIStoryboard identifier.
     - returns : 일치하는 viewController.
     */
    static func view<T>(type: T.Type, _ board: String = "Main") -> T {
        let storyboard = UIStoryboard(name: board, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
    
    /**
     Storyboard 주어진 id와 동일한 id를 가지는 viewController를 반환한다.
     - parameter id : UIViewController identifier.
     - parameter board : UIStoryboard identifier.
     - returns : 일치하는 viewController.
     */
    static func view(id: String, _ board: String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: board, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id)
    }
    
}

