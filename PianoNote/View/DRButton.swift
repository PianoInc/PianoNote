//
//  DRButton.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewDidLoad()
    }
    
    private func viewDidLoad() {
        initView()
    }
    
    func initView() {}
    
    /**
     버튼에 해당 title를 적용한다.
     - parameter text : 적용하려는 string.
     */
    func title(text: String) {
        setTitle(text, for: .normal)
    }
    
    /**
     버튼에 해당 title를 적용한다.
     - parameter text : 적용하려는 attributedString.
     */
    func title(attr: NSAttributedString) {
        setAttributedTitle(attr, for: .normal)
    }
    
    /**
     버튼 title에 해당 color를 적용한다.
     - parameter color : 적용하려는 color.
     */
    func title(color: UIColor) {
        setTitleColor(color, for: .normal)
    }
    
    /**
     버튼 title에 해당 font를 적용한다.
     - note: [UIFontTextStyle](https://developer.apple.com/documentation/uikit/uifonttextstyle)
     - parameter font : DRTextStyle.
     */
    func title(font: DRTextStyle) {
        titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle(font.rawValue))
    }
    
    /**
     버튼에 image를 적용한다.
     - parameter image : 적용하려는 image.
     */
    func image(_ image: UIImage?) {
        setImage(image, for: .normal)
        setImage(image, for: .highlighted)
    }
    
    /**
     버튼에 image를 resizing하여 적용한다.
     - parameter image : 적용하려는 image.
     - parameter size : 적용하려는 size.
     */
    func image(_ image: UIImage, size: CGSize) {
        let frame = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, imageView!.layer.isOpaque, UIScreen.main.scale)
        image.draw(in: frame)
        setImage(UIGraphicsGetImageFromCurrentImageContext(), for: .normal)
        setImage(UIGraphicsGetImageFromCurrentImageContext(), for: .highlighted)
        UIGraphicsEndImageContext()
    }
    
    /**
     버튼의 tap action을 감지하고 통지한다.
     - parameter completion : tap action 통지.
     */
    func tap(_ completion: @escaping (() -> ())) {
        _ = rx.tap.subscribe { event in
            completion()
        }
    }
    
}

