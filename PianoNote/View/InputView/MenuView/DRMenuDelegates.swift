//
//  DRMenuDelegates.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 6..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/// Accessory 메뉴 리스트.
enum DRMenuList: Int {
    case undo, redo, camera, album, drawing
}

protocol DRMenuDelegates: NSObjectProtocol {
    /**
     메뉴의 선택 처리.
     - parameter indexPath : 선택한 메뉴의 indexPath.
     */
    func action(select indexPath: IndexPath)
    /**
     Camera 화면을 close한다.
     - parameter image : 촬영한 화면의 image.
     */
    func close(camera image: UIImage?)
    /**
     Album 화면을 close한다.
     - parameter image : 선택한 사진의 image.
     */
    func close(album image: UIImage?)
    /**
     Drawing 화면을 close한다.
     - parameter image : 그림의 전체크기 image.
     - parameter drawRect : 실제로 그림이 그려진 부분의 rect값.
     */
    func close(drawing image: UIImage?, drawingRect: CGRect)
}

extension DRMenuCollectionView: DRMenuDelegates {
    
    func action(select indexPath: IndexPath) {
        if indexPath.row == DRMenuList.undo.rawValue {
            guard let manager = targetView.undoManager, manager.canUndo else {return}
            manager.undo()
        } else if indexPath.row == DRMenuList.redo.rawValue {
            guard let manager = targetView.undoManager, manager.canRedo else {return}
            manager.redo()
        } else {
            let viewRect = CGRect(x: 0, y: 0, width: mainSize.width, height: inputHeight)
            device(orientationLock: false)
            if indexPath.row == DRMenuList.camera.rawValue {
                DRAuth.share.request(camera: {
                    let cameraView = DRCameraView(frame: viewRect)
                    cameraView.delegates = self
                    self.loadCustomInput(view: cameraView, fullscreen: true)
                    self.device(orientationLock: true)
                })
            } else if indexPath.row == DRMenuList.album.rawValue {
                DRAuth.share.request(photo: {
                    let albumView = DRAlbumView(frame: viewRect)
                    albumView.delegates = self
                    self.loadCustomInput(view: albumView, fullscreen: false)
                })
            } else if indexPath.row == DRMenuList.drawing.rawValue {
                DRAuth.share.request(photo: {
                    let drawingView = DRDrawingView(frame: viewRect, image: nil)
                    drawingView.delegates = self
                    self.loadCustomInput(view: drawingView, fullscreen: true)
                })
            }
        }
    }
    
    /**
     Custom inputView의 reload를 진행한다.
     - parameter view : load하고자 하는 custom inputView.
     - parameter animate : 전체화면으로 실행할지의 여부.
     */
    private func loadCustomInput(view: UIView, fullscreen animate: Bool) {
        targetView.inputView = view
        targetView.reloadInputViews()
        if animate {fillCustomInput()}
    }
    
    func close(camera image: UIImage?) {
        targetView.inputView = nil
        targetView.reloadInputViews()
    }
    
    func close(album image: UIImage?) {
        targetView.inputView = nil
        targetView.reloadInputViews()
    }
    
    func close(drawing image: UIImage?, drawingRect: CGRect) {
        targetView.inputView = nil
        targetView.reloadInputViews()
    }
    
}

