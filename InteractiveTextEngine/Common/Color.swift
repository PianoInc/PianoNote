//
//  Color.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     #RRGGBB로 표현되는 hex값으로 init한다.
     - note: #의 포함 여부는 상관없음.
     - parameter hex6: 6자리 hex값.
     */
    public convenience init(hex6: String) {
        let scan = Scanner(string: hex6.replacingOccurrences(of: "#", with: ""))
        var hex6: UInt32 = 0
        scan.scanHexInt32(&hex6)
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    /**
     #RRGGBBAA로 표현되는 hex값으로 init한다.
     - note: #의 포함 여부는 상관없음.
     - parameter hex8: 6자리 hex + 2자리 alpha값.
     */
    public convenience init(hex8: String) {
        let scan = Scanner(string: hex8.replacingOccurrences(of: "#", with: ""))
        var hex8: UInt32 = 0
        scan.scanHexInt32(&hex8)
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public var hexString: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"%06x", rgb)
    }
    
    //랜덤 컬러 get
    public static func randomColor() -> UIColor {
        srand48(Int(arc4random()))
        
        var red = 0.0
        var green = 0.0
        var blue = 0.0
        
        while(red < 0.1 || red > 0.84) { red = drand48() }
        while(green < 0.1 || green > 0.84) { green = drand48() }
        while(blue < 0.1 || blue > 0.84) { blue = drand48() }
        
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
}

extension UIColor {
    static let point = UIColor(hex6: "007AFF")
    static let basic = UIColor(hex6: "000000")
}
