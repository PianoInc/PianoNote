//
//  DRMenuDelegates.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 6..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

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
        if indexPath.row == 0 {
            guard let manager = targetView.undoManager, manager.canUndo else {return}
            manager.undo()
        } else if indexPath.row == 1 {
            guard let manager = targetView.undoManager, manager.canRedo else {return}
            manager.redo()
        } else {
            let viewRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: inputHeight)
            device(orientationLock: false)
            if indexPath.row == 2 {
                DRAuth.share.request(camera: {
                    let drawingView = DRCameraView(frame: viewRect)
                    drawingView.delegates = self
                    self.loadCustomInput(view: drawingView)
                    self.device(orientationLock: true)
                })
            } else if indexPath.row == 3 {
                DRAuth.share.request(photo: {
                    let drawingView = DRAlbumView(frame: viewRect)
                    drawingView.delegates = self
                    self.loadCustomInput(view: drawingView)
                })
            } else {
                DRAuth.share.request(photo: {
                    let drawingView = DRDrawingView(frame: viewRect, image: nil)
                    drawingView.delegates = self
                    self.loadCustomInput(view: drawingView)
                })
            }
        }
    }
    
    /**
     Custom inputView의 reload를 진행한다.
     - parameter view : load하고자 하는 custom inputView.
     */
    private func loadCustomInput(view: UIView) {
        targetView.inputView = view
        targetView.reloadInputViews()
        fillCustomInput()
    }
    
    func close(camera image: UIImage?) {
        targetView.inputView = nil
        targetView.reloadInputViews()
    }
    
    func close(album image: UIImage?) {
        
    }
    
    func close(drawing image: UIImage?, drawingRect: CGRect) {
        targetView.inputView = nil
        targetView.reloadInputViews()
    }
    
}
