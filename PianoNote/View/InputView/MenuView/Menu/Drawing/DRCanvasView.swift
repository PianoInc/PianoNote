//
//  DRCanvasView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 5..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

struct DRDrawingPen {
    var color: UIColor = .black
    var width: CGFloat = 5
    var alpha: CGFloat = 1
    var scale: CGFloat = 1 {didSet {
        width = width * scale
        }}
}

class DRCanvasView: UIView {
    
    let canvas = UIImageView()
    let drawingUndoManager = DRDrawingUndoManager()
    var drawingPen = DRDrawingPen()
    
    private let imageView = UIImageView()
    
    private let path = UIBezierPath()
    private var points = Array(repeating: CGPoint.zero, count: 5)
    private var pointIndex = 0
    private var pointMoved = false
    
    private var minPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
    private var maxPoint = CGPoint.zero
    
    /// canvas에서 실제로 그림이 그려진 부분의 crop rect를 반환한다.
    var drawingRect: CGRect {
        if maxPoint != .zero {
            return CGRect(x: minPoint.x, y: minPoint.y,
                          width: maxPoint.x - minPoint.x, height: maxPoint.y - minPoint.y)
        }
        return .zero
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = .white
        path.lineCapStyle = .round
        canvas.backgroundColor = .white
        imageView.backgroundColor = .clear
        addSubview(canvas)
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        canvas.frame = bounds
        imageView.frame = bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let location = touches.first!.location(in: self)
        drawing(point: location)
        
        pointMoved = false
        pointIndex = 0
        points[0] = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let location = touches.first!.location(in: self)
        drawing(point: location)
        
        pointMoved = true
        pointIndex += 1
        points[pointIndex] = location
        
        if pointIndex == 4 {
            points[3] = CGPoint(x: (points[2].x + points[4].x) / 2, y: (points[2].y + points[4].y) / 2)
            path.move(to: points[0])
            path.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            points[0] = points[3]
            points[1] = points[4]
            pointIndex = 1
        }
        
        strokePath()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEnded(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let location = touches.first!.location(in: self)
        drawing(point: location)
        
        if !pointMoved {
            path.move(to: points[0])
            path.addLine(to: points[0])
            strokePath()
        }
        mergePaths()
        
        path.removeAllPoints()
        pointIndex = 0
    }
    
    /// drawingRect 계산을 위한 최소/최대 point를 저장한다.
    private func drawing(point: CGPoint) {
        /// 펜이 굵기를 가지기 때문에 3배에 해당하는 margin값을 준다.
        let offset = drawingPen.width * 3
        if minPoint.x > point.x {
            let valueX = point.x - offset
            minPoint = CGPoint(x: (valueX > 0) ? valueX : 0, y: minPoint.y)
        }
        if minPoint.y > point.y {
            let valueY = point.y - offset
            minPoint = CGPoint(x: minPoint.x, y: (valueY > 0) ? valueY : 0)
        }
        if maxPoint.x < point.x {
            let valueX = point.x + (offset * 2)
            maxPoint = CGPoint(x: (valueX < bounds.maxX) ? valueX : bounds.maxX, y: maxPoint.y)
        }
        if maxPoint.y < point.y {
            let valueY = point.y + (offset * 2)
            maxPoint = CGPoint(x: maxPoint.x, y: (valueY < bounds.maxY) ? valueY : bounds.maxY)
        }
    }
    
    /// imageView에 그림을 그린다.
    private func strokePath() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        path.lineWidth = drawingPen.width
        drawingPen.color.withAlphaComponent(drawingPen.alpha).setStroke()
        path.stroke(with: .normal, alpha: 1)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    /// canvas에 imageView를 merge한다.
    private func mergePaths() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        canvas.image?.draw(in: bounds)
        imageView.image?.draw(in: bounds)
        canvas.image = UIGraphicsGetImageFromCurrentImageContext()
        drawingUndoManager.append(canvas.image)
        imageView.image = nil
        UIGraphicsEndImageContext()
    }
    
}

