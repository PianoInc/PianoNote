//
//  DRAuth.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class DRAuth: NSObject {
    
    static let share = DRAuth()
    
    /**
     Camera 사용 권한 요청.
     - parameter camera : 요청에 대한 결과.
     */
    func request(camera: @escaping (() -> ())) {
        AVCaptureDevice.requestAccess(for: .video) { permission in
            DispatchQueue.main.async {
                if permission {
                    camera()
                } else {
                    self.alert(title: "", message: "requestCamera".locale)
                }
            }
        }
    }
    
    /**
     Photo album 사용 권한 요청.
     - parameter photo : 요청에 대한 결과.
     */
    func request(photo: @escaping (() -> ())) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    photo()
                } else {
                    self.alert(title: "", message: "requestPhoto".locale)
                }
            }
        }
    }
    
    /**
     요청실패 알림창을 생성한다.
     - parameter title : 알림창 타이틀.
     - parameter message : 알림창 내용.
     */
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "cancel".locale, style: .cancel)
        let settingAction = UIAlertAction(title: "setting".locale, style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(settingAction)
        alert.addAction(dismissAction)
        
        if let topViewController = UIWindow.topVC {
            topViewController.present(alert, animated: true)
        }
    }
    
}

