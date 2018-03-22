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

