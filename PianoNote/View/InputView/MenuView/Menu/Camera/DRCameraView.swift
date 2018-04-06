//
//  DRCameraView.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AVFoundation

class DRCameraView: UIView {
    
    weak var delegates: DRMenuDelegates!
    
    let previewView = UIView()
    private let flashButton = makeView(UIButton()) {
        $0.setTitle("flash", for: .normal)
    }
    private let cancelButton = makeView(UIButton()) {
        $0.setTitle("cancel".locale, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.preferred(font: 17, weight: .regular)
    }
    private let shotButton = makeView(UIButton()) {
        $0.setTitle("shot", for: .normal)
    }
    private let rotateButton = makeView(UIButton()) {
        $0.setTitle("rotate", for: .normal)
    }
    
    var captureSession: AVCaptureSession?
    var captureOutput: AVCapturePhotoOutput?
    var inputBack: AVCaptureDeviceInput?
    var inputFront: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var captureCompletion: ((UIImage?) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initConst()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        initConst()
    }
    
    private func initView() {
        super.didMoveToWindow()
        backgroundColor = .black
        flashButton.addTarget(self, action: #selector(action(flash:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(action(close:)), for: .touchUpInside)
        shotButton.addTarget(self, action: #selector(action(shot:)), for: .touchUpInside)
        rotateButton.addTarget(self, action: #selector(action(rotate:)), for: .touchUpInside)
        addSubview(previewView)
        addSubview(flashButton)
        addSubview(cancelButton)
        addSubview(shotButton)
        addSubview(rotateButton)
        
        DispatchQueue.global().async {
            self.initDevice()
            DispatchQueue.main.async {
                self.initPreview()
            }
        }
    }
    
    private func initConst() {
        func constraint() {
            makeConst(flashButton) {
                $0.leading.equalTo(self.safeInset.left)
                $0.top.equalTo(self.safeInset.top)
                $0.width.equalTo(self.inputHeight * 0.172)
                $0.height.equalTo(self.flashButton.snp.width)
            }
            makeConst(cancelButton) {
                $0.leading.equalTo(self.safeInset.left)
                $0.bottom.equalTo(-self.safeInset.bottom)
                $0.width.equalTo(self.inputHeight * 0.275)
                $0.height.equalTo(self.cancelButton.snp.width)
            }
            makeConst(shotButton) {
                $0.leading.equalTo(UIScreen.main.bounds.width / 2 - (self.inputHeight * 0.275) / 2)
                $0.bottom.equalTo(-self.safeInset.bottom)
                $0.width.equalTo(self.inputHeight * 0.275)
                $0.height.equalTo(self.shotButton.snp.width)
            }
            makeConst(rotateButton) {
                $0.trailing.equalTo(-self.safeInset.right)
                $0.bottom.equalTo(-self.safeInset.bottom)
                $0.width.equalTo(self.inputHeight * 0.275)
                $0.height.equalTo(self.rotateButton.snp.width)
            }
            makeConst(previewView) {
                $0.leading.equalTo(self.safeInset.left)
                $0.trailing.equalTo(-self.safeInset.right)
                $0.top.equalTo(self.inputHeight * 0.2 + self.safeInset.top)
                $0.bottom.equalTo(-(self.inputHeight * 0.3 + self.safeInset.bottom))
            }
        }
        constraint()
        device(orientationDidChange: { [weak self] _ in self?.initConst()})
    }
    
    @objc private func action(flash: UIButton) {
        flash.isSelected = !flash.isSelected
        flashMode = flash.isSelected ? .on : .off
    }
    
    @objc private func action(close: UIButton) {
        DispatchQueue.global().async {
            self.captureSession?.stopRunning()
            DispatchQueue.main.async {
                self.delegates.close(camera: nil)
            }
        }
    }
    
    @objc private func action(shot: UIButton) {
        cameraShot(completion: {
            self.captureSession?.stopRunning()
            self.delegates.close(camera: $0)
        })
    }
    
    @objc private func action(rotate: UIButton) {
        reloadDevice()
    }
    
}

