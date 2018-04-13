//
//  DRCameraCapture.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 5..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import Photos

extension DRCameraView: AVCapturePhotoCaptureDelegate {
    
    /// Camera 촬영 진행.
    func cameraShot(completion: @escaping (UIImage?) -> ()) {
        captureCompletion = completion
        let setting = AVCapturePhotoSettings()
        setting.flashMode = flashMode
        captureOutput?.capturePhoto(with: setting, delegate: self)
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer), let image = UIImage(data: data) {
            DRAuth.share.request(photo: {
                let croppedImage = self.crop(image: image)
                self.captureCompletion?(croppedImage)
                try? PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest.creationRequestForAsset(from: croppedImage)
                }
            })
        } else {
            captureCompletion?(nil)
        }
    }
    
    /**
     화면에 보여지고 있는 화면 만큼 image를 crop하고 orientation을 portrait으로 설정하여 반환한다.
     - parameter image : 원본 image.
     - returns : crop / orientaion 작업이 완료된 image.
     */
    private func crop(image: UIImage) -> UIImage {
        var croppedImage = image
        if UIApplication.shared.statusBarOrientation == .portrait {
            let scale = image.size.width / previewLayer!.bounds.width
            let width = previewLayer!.bounds.height * scale
            let height = image.size.width
            let x: CGFloat = image.size.height / 2 - width / 2
            let y: CGFloat = 0
            let rect = CGRect(x: x, y: y, width: width, height: height)
            let cgImage = croppedImage.cgImage!.cropping(to: rect)!
            
            croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
            if UIDevice.current.orientation == .portraitUpsideDown {
                croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .left)
            } else if UIDevice.current.orientation == .landscapeLeft {
                croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .up)
            } else if UIDevice.current.orientation == .landscapeRight {
                croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .down)
            }
        } else {
            let scale = image.size.height / previewLayer!.bounds.width
            let width = image.size.height
            let height = previewLayer!.bounds.height * scale
            let x: CGFloat = 0
            let y: CGFloat = image.size.width / 2 - height / 2
            let rect = CGRect(x: x, y: y, width: width, height: height)
            let cgImage = croppedImage.cgImage!.cropping(to: rect)!
            
            if UIApplication.shared.statusBarOrientation == .landscapeLeft {
                croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .down)
                if UIDevice.current.orientation == .landscapeLeft {
                    croppedImage = UIImage(cgImage: cgImage)
                } else if UIDevice.current.orientation == .portrait {
                    croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
                } else if UIDevice.current.orientation == .portraitUpsideDown {
                    croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .left)
                }
            } else if UIApplication.shared.statusBarOrientation == .landscapeRight {
                croppedImage = UIImage(cgImage: cgImage)
                if UIDevice.current.orientation == .landscapeRight {
                    croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .down)
                } else if UIDevice.current.orientation == .portraitUpsideDown {
                    croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .left)
                } else if UIDevice.current.orientation == .portrait {
                    croppedImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
                }
            }
        }
        return croppedImage
    }
    
}

