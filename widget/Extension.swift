//
//  Extension.swift
//  widget
//
//  Created by JangDoRi on 2018. 4. 4..
//  Copyright © 2018년 piano. All rights reserved.
//
// Target Membership을 공유하지 못하는 내역을 정의하는 곳.

import UIKit

/**
 Device의 가로 세로중 더 작은 방향의 화면크기 값, iPhone의 최대 minSize인
 414를 넘을시엔 기기간 일정비율 유지를 위해서 414를 반환한다.
 */
var minSize: CGFloat {
    var size = UIScreen.main.bounds.width
    if size > UIScreen.main.bounds.height {size = UIScreen.main.bounds.height}
    return (size < 414) ? size : 414
}

