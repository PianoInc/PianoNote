//
//  Device.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension NSObject {
    
    /**
     Device의 가로 세로중 더 작은 방향의 화면크기 값,
     iPhone의 최대 minSize인 414를 넘을시엔
     기기간 일정비율 유지를 위해서 414를 반환한다.
     */
    var minSize: CGFloat {
        var size = UIScreen.main.bounds.width
        if size > UIScreen.main.bounds.height {size = UIScreen.main.bounds.height}
        return (size < 414) ? size : 414
    }
    
    /// Device의 가로 세로중 더 큰 방향의 화면크기를 반환한다.
    var maxSize: CGFloat {
        var size = UIScreen.main.bounds.width
        if size < UIScreen.main.bounds.height {size = UIScreen.main.bounds.height}
        return size
    }
    
    /// Device의 화면크기를 반환한다.
    var mainSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    /// StatusBar의 높이를 반환한다.
    var statusHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    /// NavigationBar의 높이를 반환한다.
    var naviHeight: CGFloat {
        if let navigationController = UIWindow.topVC?.navigationController {
            return navigationController.navigationBar.frame.height
        }
        return 0
    }
    
    /// ToolBar의 높이를 반환한다.
    var toolHeight: CGFloat {
        guard let navigationController = UIWindow.topVC?.navigationController else {return 0}
        if !navigationController.isToolbarHidden {
            return navigationController.toolbar.frame.height
        }
        return 0
    }
    
    /// iPhoneX 대응 safeArea Inset값.
    var safeInset: UIEdgeInsets {
        if UIScreen.main.bounds.size == CGSize(width: 375, height: 812) {
            return UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
        } else if UIScreen.main.bounds.size == CGSize(width: 812, height: 375) {
            return UIEdgeInsets(top: 0, left: 44, bottom: 21, right: 44)
        }
        return .zero
    }
    
    /**
     호출하는 순간의 statusBarOrientation을 참조하여 orientation을 고정/해제한다.
     - parameter lock : 고정여부.
     */
    func device(orientationLock: Bool) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            var orientationMask: UIInterfaceOrientationMask {
                switch UIApplication.shared.statusBarOrientation {
                case .landscapeLeft:
                    return .landscapeLeft
                case .landscapeRight:
                    return .landscapeRight
                default:
                    return .portrait
                }
            }
            appDelegate.orientationLock = orientationLock ? orientationMask : .allButUpsideDown
        }
    }
    
    /**
     Device의 orientation 변화를 감지하고 통지한다.
     - warning : Use unowned or weak for avoid memory leak.
     - parameter completion : 변화된 orientation값.
     */
    func device(orientationDidChange completion: @escaping (UIDeviceOrientation) -> ()) {
        let name = NSNotification.Name.UIDeviceOrientationDidChange
        let notificationRx = NotificationCenter.default.rx.notification(name).takeUntil(rx.deallocated)
        _ = notificationRx.skip(0.5, scheduler: MainScheduler.instance).subscribe { notification in
            switch UIDevice.current.orientation {
            case .portrait, .landscapeLeft, .landscapeRight:
                completion(UIDevice.current.orientation)
            default:
                break
            }
        }
    }
    
    /**
     Device의 keyboard가 올라오려는 순간을 감지하고 통지한다.
     - warning : Use unowned or weak for avoid memory leak.
     - parameter completion : 올라온 keyboard의 height.
     */
    func device(keyboardWillShow completion: @escaping (CGFloat) -> ()) {
        let type = NSNotification.Name.UIKeyboardWillShow
        let notificationRx = NotificationCenter.default.rx.notification(type).takeUntil(rx.deallocated)
        _ = notificationRx.skip(0.5, scheduler: MainScheduler.instance).subscribe {
            if let rect = $0.element?.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect? {
                completion(rect.height)
            } else {
                completion(0)
            }
        }
    }
    
    /**
     Device의 keyboard가 내려간 순간을 감지하고 통지한다.
     - warning : Use unowned or weak for avoid memory leak.
     - parameter completion : 내려간 keyboard의 height.
     */
    func device(keyboardDidHide completion: @escaping (CGFloat) -> ()) {
        let type = NSNotification.Name.UIKeyboardDidHide
        let notificationRx = NotificationCenter.default.rx.notification(type).takeUntil(rx.deallocated)
        _ = notificationRx.skip(0.5, scheduler: MainScheduler.instance).subscribe {
            if let rect = $0.element?.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect? {
                completion(rect.height)
            } else {
                completion(0)
            }
        }
    }
    
}

