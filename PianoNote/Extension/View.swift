//
//  View.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

/**
 View 생성 helper.
 - parameter view : 생성하고자 하는 view.
 - parameter attr : View에 대한 attribute 선언부.
 - returns : Attribute가 설정된 view.
 */
func initView<T>(_ view: T, _ attr: ((T) -> ())) -> T {
    attr(view)
    return view
}

