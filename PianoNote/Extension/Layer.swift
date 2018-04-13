//
//  asd.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     해당 View에 layer의 cornerRadius를 조정한다. (default : 둥근 사각형)
     - parameter rad : 주고자 하는 radius값.
     */
    func corner(rad: CGFloat = 0) {
        guard rad == 0 else {layer.cornerRadius = rad; return}
        var minSize = bounds.width
        if minSize > bounds.height {minSize = bounds.height}
        layer.cornerRadius = minSize / 2
    }
    
    /**
     해당 View에 layer의 shadow를 조정한다.
     - parameter hex : 주고자 하는 color hex값.
     - parameter offset : 주고자 하는 offset값.
     - parameter rad : 주고자 하는 radius값.
     */
    func shadow(hex: String, offset: [CGFloat], rad: CGFloat) {
        let color = (hex.count == 6) ? UIColor(hex6: hex) : UIColor(hex8: hex)
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: offset[0], height: offset[1])
        layer.shadowRadius = rad
    }
    
    /**
     해당 View에 layer의 shadow를 조정한다.
     - parameter color : 주고자 하는 color값.
     - parameter offset : 주고자 하는 offset값.
     - parameter rad : 주고자 하는 radius값.
     */
    func shadow(color: UIColor, offset: [CGFloat], rad: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: offset[0], height: offset[1])
        layer.shadowRadius = rad
    }
    
    /**
     해당 View에 layer의 border를 조정한다.
     - parameter hex : 주고자 하는 color hex값.
     - parameter width : 주고자 하는 width값.
     */
    func border(hex: String, width: CGFloat) {
        let color = (hex.count == 6) ? UIColor(hex6: hex) : UIColor(hex8: hex)
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    /**
     해당 View에 layer의 border를 조정한다.
     - parameter color : 주고자 하는 color값.
     - parameter width : 주고자 하는 width값.
     */
    func border(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
}

