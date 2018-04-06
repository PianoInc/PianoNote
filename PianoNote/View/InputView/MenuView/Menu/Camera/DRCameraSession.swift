//
//  DRCameraSession.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 5..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AVFoundation

extension DRCameraView {
    
    func initDevice() {
        // Device의 camera를 가져와 setting한다.
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices.compactMap {$0}
        for device in devices {
            if device.position == .front {
                inputFront = try? AVCaptureDeviceInput(device: device)
            }
            if device.position == .back {
                inputBack = try? AVCaptureDeviceInput(device: device)
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    try? device.lockForConfiguration()
                    device.focusMode = .continuousAutoFocus
                    device.unlockForConfiguration()
                }
            }
        }
        
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else {return}
        
        // 뒷면 camera를 우선으로 session에 input으로 연결시킨다.
        if let inputBack = self.inputBack, captureSession.canAddInput(inputBack) {
            captureSession.addInput(inputBack)
        } else if let inputFront = self.inputFront, captureSession.canAddInput(inputFront) {
            captureSession.addInput(inputFront)
        }
        
        captureOutput = AVCapturePhotoOutput()
        guard let captureOutput = captureOutput else {return}
       
        // Session에 output을 연결시킨다.
        if captureSession.canAddOutput(captureOutput) {
            let jpegSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])
            captureOutput.setPreparedPhotoSettingsArray([jpegSetting])
            captureSession.addOutput(captureOutput)
        }
        
        // Camera 구동 시작.
        captureSession.startRunning()
    }
    
    func initPreview() {
        guard let captureSession = captureSession else {return}
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = previewView.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        // statusBarOrientation에 따라 사용자에게 올바르게 보일 수 있도록 videoOrientation 설정을 한다.
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
        previewView.layer.addSublayer(previewLayer!)
    }
    
    /// 현재 Input되고 있는 camera의 앞뒤 방향을 반대로 바꾸어 reload한다.
    func reloadDevice() {
        guard let captureSession = captureSession else {return}
        guard let inputBack = self.inputBack, let inputFront = self.inputFront else {return}
        captureSession.beginConfiguration()
        if captureSession.inputs.contains(inputBack) {
            captureSession.removeInput(inputBack)
            captureSession.addInput(inputFront)
        } else {
            captureSession.removeInput(inputFront)
            captureSession.addInput(inputBack)
        }
        captureSession.commitConfiguration()
    }
    
}

