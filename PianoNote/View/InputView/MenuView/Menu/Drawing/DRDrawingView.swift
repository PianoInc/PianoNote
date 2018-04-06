//
//  DRDrawingView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRDrawingView: UIView {
    
    weak var delegates: DRMenuDelegates!
    
    private let canvasView = DRCanvasView()
    
    private let menuView = UIView()
    private let closeButton = makeView(UIButton()) {
        $0.setTitle("Clo", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    private let undoButton = makeView(UIButton()) {
        $0.setTitle("Un", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    private let redoButton = makeView(UIButton()) {
        $0.setTitle("Re", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    private let clearButton = makeView(UIButton()) {
        $0.setTitle("Cle", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    convenience init(frame: CGRect, image: UIImage?) {
        self.init(frame: frame)
        canvasView.canvas.image = image
        initView()
        initConst()
    }
    
    private func initView() {
        backgroundColor = UIColor(hex6: "e5e5e5")
        menuView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        canvasView.frame = CGRect(x: safeInset.left, y: safeInset.top,
                                  width: UIScreen.main.bounds.width - safeInset.left - safeInset.right,
                                  height: UIScreen.main.bounds.height - safeInset.top - safeInset.bottom)
        closeButton.addTarget(self, action: #selector(action(close:)), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(action(undo:)), for: .touchUpInside)
        redoButton.addTarget(self, action: #selector(action(redo:)), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(action(clear:)), for: .touchUpInside)
        addSubview(canvasView)
        addSubview(menuView)
        addSubview(closeButton)
        addSubview(undoButton)
        addSubview(redoButton)
        addSubview(clearButton)
    }
    
    private func initConst() {
        func constraint() {
            makeConst(menuView) {
                $0.leading.equalTo(self.safeInset.left)
                $0.trailing.equalTo(self.safeInset.right)
                $0.top.equalTo(self.safeInset.top)
                $0.height.equalTo(self.minSize * 0.08)
            }
            makeConst(closeButton) {
                $0.leading.equalTo(self.minSize * 0.0266 + self.safeInset.left)
                $0.top.equalTo(self.safeInset.top)
                $0.width.equalTo(self.minSize * 0.08)
                $0.height.equalTo(self.minSize * 0.08)
            }
            makeConst(undoButton) {
                $0.leading.equalTo(self.closeButton.snp.trailing).offset(self.minSize * 0.0266)
                $0.top.equalTo(self.safeInset.top)
                $0.width.equalTo(self.minSize * 0.08)
                $0.height.equalTo(self.minSize * 0.08)
            }
            makeConst(redoButton) {
                $0.leading.equalTo(self.undoButton.snp.trailing)
                $0.top.equalTo(self.safeInset.top)
                $0.width.equalTo(self.minSize * 0.08)
                $0.height.equalTo(self.minSize * 0.08)
            }
            makeConst(clearButton) {
                $0.leading.equalTo(self.redoButton.snp.trailing)
                $0.top.equalTo(self.safeInset.top)
                $0.width.equalTo(self.minSize * 0.08)
                $0.height.equalTo(self.minSize * 0.08)
            }
        }
        constraint()
        device(orientationDidChange: { [weak self] _ in
            self?.initConst()
            self?.fillCustomInput(animate: false)
            self?.canvasOrientation()
        })
    }
    
    /// 현재 orientation 맞추어 canvasView를 scaleAspectFit 처리한다.
    private func canvasOrientation() {
        let oldValue = max(canvasView.bounds.width, canvasView.bounds.height)
        if canvasView.bounds.width < canvasView.bounds.height {
            let scale = (UIScreen.main.bounds.height - safeInset.top - safeInset.bottom) / canvasView.bounds.height
            let width = canvasView.bounds.width * scale
            let height = canvasView.bounds.height * scale
            let x = UIScreen.main.bounds.width / 2 - width / 2
            let y: CGFloat = safeInset.top
            canvasView.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            let scale = (UIScreen.main.bounds.width - safeInset.left - safeInset.right) / canvasView.bounds.width
            let width = canvasView.bounds.width * scale
            let height = canvasView.bounds.height * scale
            let x: CGFloat = safeInset.left
            var y =  UIScreen.main.bounds.height / 2 - height / 2
            if UIApplication.shared.statusBarOrientation.isLandscape {y = 0}
            canvasView.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        let newValue = max(canvasView.bounds.width, canvasView.bounds.height)
        if oldValue != newValue {canvasView.drawingPen.scale = newValue / oldValue}
    }
    
    @objc private func action(close: UIButton) {
        if let image = canvasView.canvas.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            delegates.close(drawing: image, drawingRect: canvasView.drawingRect)
        } else {
            delegates.close(drawing: nil, drawingRect: .zero)
        }
    }
    
    @objc private func action(undo: UIButton) {
        if self.canvasView.drawingUndoManager.canUndo {
            self.canvasView.drawingUndoManager.undo()
            self.canvasView.canvas.image = self.canvasView.drawingUndoManager.lastImage
        }
    }
    
    @objc private func action(redo: UIButton) {
        if self.canvasView.drawingUndoManager.canRedo {
            self.canvasView.drawingUndoManager.redo()
            self.canvasView.canvas.image = self.canvasView.drawingUndoManager.lastImage
        }
    }
    
    @objc private func action(clear: UIButton) {
        if self.canvasView.drawingUndoManager.canClear {
            self.canvasView.drawingUndoManager.clear()
            self.canvasView.canvas.image = self.canvasView.drawingUndoManager.lastImage
        }
    }
    
}

