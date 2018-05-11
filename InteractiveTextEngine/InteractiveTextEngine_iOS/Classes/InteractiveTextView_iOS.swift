//
//  InteractiveTextView_iOS.swift
//  InteractiveTextEngine_iOS
//
//  Created by 김범수 on 2018. 3. 22..
//

import Foundation
import CoreText


open class InteractiveTextView: UITextView {
    let dispatcher = InteractiveAttachmentCellDispatcher() //cell frame delegate
    private var contentOffsetObserver: NSKeyValueObservation?
    private var boundsObserver: NSKeyValueObservation?
    var displayLink: CADisplayLink?
    var animationLayer: CAShapeLayer?
    
    open weak var interactiveDataSource: InteractiveTextViewDataSource?
    open weak var interactiveDelegate: InteractiveTextViewDelegate?
    
    public var visibleBounds: CGRect {
        return CGRect(x: self.contentOffset.x, y:self.contentOffset.y,width: self.bounds.size.width,height: self.bounds.size.height)
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {

        let size = CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)
        let newContainer = NSTextContainer(size: size)
        let newLayoutManager = InteractiveLayoutManager()
        let newTextStorage = InteractiveTextStorage()
        
        newLayoutManager.addTextContainer(newContainer)
        newTextStorage.addLayoutManager(newLayoutManager)
        
        super.init(frame: frame, textContainer: newContainer)
        
        newTextStorage.textView = self
        newLayoutManager.textView = self
        dispatcher.superView = self
        self.backgroundColor = UIColor.clear
        animationLayer = CAShapeLayer()
        animationLayer?.frame = self.bounds.divided(atDistance: 0.0, from: .minYEdge).remainder
        
        self.layer.insertSublayer(animationLayer!, at: 0)
        
        validateDisplayLink()
        setObserver()
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        
        let newTextView = InteractiveTextView(frame: self.frame)

        //get constraints
        var constraints: Array<NSLayoutConstraint> = []
        self.constraints.forEach {
            let firstItem: AnyObject!, secondItem: AnyObject!

            if let unwrappedFirst = $0.firstItem as? InteractiveTextView, unwrappedFirst == self {
                firstItem = self
            } else {
                firstItem = $0.firstItem
            }

            if let unwrappedSecond = $0.secondItem as? InteractiveTextView, unwrappedSecond == self {
                secondItem = self
            } else {
                secondItem = $0.secondItem
            }

            constraints.append(
                    NSLayoutConstraint(item: firstItem,
                            attribute: $0.firstAttribute,
                            relatedBy: $0.relation,
                            toItem: secondItem,
                            attribute: $0.secondAttribute,
                            multiplier: $0.multiplier,
                            constant: $0.constant))
        }



        newTextView.addConstraints(constraints)
        newTextView.autoresizingMask = self.autoresizingMask
        newTextView.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints


        newTextView.autocorrectionType = self.autocorrectionType
        newTextView.attributedText = self.attributedText
        newTextView.backgroundColor = self.backgroundColor
        newTextView.dataDetectorTypes = self.dataDetectorTypes
        newTextView.returnKeyType = self.returnKeyType
        newTextView.keyboardAppearance = self.keyboardAppearance
        newTextView.keyboardDismissMode = self.keyboardDismissMode
        newTextView.keyboardType = self.keyboardType
        (newTextView.layoutManager as? InteractiveLayoutManager)?.textView = self

        return newTextView
    }


    deinit {
        contentOffsetObserver?.invalidate()
        boundsObserver?.invalidate()
        contentOffsetObserver = nil
    }
    
    func setObserver() {
        contentOffsetObserver = observe(\.contentOffset, options: [.old, .new]) {[weak self] (object, change) in
            guard let new = change.newValue, let old = change.oldValue else {return}
            if new != old {
                guard let visibleBounds = self?.visibleBounds else {return}
                self?.dispatcher.visibleRectChanged(rect: visibleBounds)
            }
        }
        
        boundsObserver = observe(\.bounds, options:[.new]) { [weak self] (_, change) in
            guard let newBounds = change.newValue else {return}
            if newBounds.origin.y >= 0 {
                self?.animationLayer?.frame = newBounds
            } else {
                self?.animationLayer?.frame = newBounds.divided(atDistance: -newBounds.origin.y, from: .minYEdge).remainder
            }
        }
    }
}
