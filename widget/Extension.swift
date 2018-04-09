//
//  Extension.swift
//  widget
//
//  Created by JangDoRi on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 Device의 가로 세로중 더 작은 방향의 화면크기 값, iPhone의 최대 minSize인
 414를 넘을시엔 기기간 일정비율 유지를 위해서 414를 반환한다.
 */
var minSize: CGFloat {
    var size = UIScreen.main.bounds.width
    if size > UIScreen.main.bounds.height {size = UIScreen.main.bounds.height}
    return (size < 414) ? size : 414
}

/**
 Device의 orientation 변화를 감지하고 통지한다.
 - warning : Use unowned or weak for avoid memory leak.
 - parameter completion : 변화된 orientation값.
 */
func device(orientationDidChange completion: @escaping (UIDeviceOrientation) -> ()) {
    let name = NSNotification.Name.UIDeviceOrientationDidChange
    let center = NotificationCenter.default
    let notificationRx = center.rx.notification(name).takeUntil(center.rx.deallocated)
    _ = notificationRx.skip(0.5, scheduler: MainScheduler.instance).subscribe { notification in
        switch UIDevice.current.orientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            completion(UIDevice.current.orientation)
        default:
            break
        }
    }
}

