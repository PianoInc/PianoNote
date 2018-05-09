
//
//  NoteListPanGestureRecognizer.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 7..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass



class NoteListGestureRecognizer: UIGestureRecognizer {
    
    ///Swiped to left or right
    enum ActivationState {
        case none
        case left
        case right
    }
    
    private var startLocation: CGPoint?
    
    var distance: CGFloat = 0.0
    
    var isActivated = false
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    override func reset() {
        super.reset()
        startLocation = nil
        distance = 0
        isActivated = false
    }
//    override func shouldRequireFailure(of otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
//            return isActivated != .none
//        }
//        return false
//    }
//
//    override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
//            return true
//        }
//        return false
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
        
        guard let touch = touches.first, touches.count == 1,
            let myView = self.view else {return}
        startLocation = touch.location(in: myView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        state = .changed
        
        guard let touch = touches.first, touches.count == 1,
            let myView = self.view, startLocation != nil else {return}
        let currentLocation = touch.location(in: myView)
        
        if isActivated == false {
            if abs(currentLocation.x - startLocation!.x) > 10 {
                startLocation = currentLocation
                distance = currentLocation.x - startLocation!.x
                isActivated = true
            }
        } else {
            distance = currentLocation.x - startLocation!.x
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        state = .ended
        startLocation = nil
        isActivated = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)

        state = .cancelled

        startLocation = nil
        isActivated = false
    }
    
}
