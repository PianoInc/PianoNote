//
//  DrawingUndoManager.swift
//  PianoNote
//
//  Created by JangDoRi on 2018. 4. 5..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class DRDrawingUndoManager {
    
    private var undoList = [UIImage]()
    private var redoList = [UIImage]()
    /// 최대 저장 한도.
    var maxSize = 50
    
    /// undo 가능 여부.
    var canUndo: Bool {
        return undoList.count > 0
    }
    
    /// redo 가능 여부.
    var canRedo: Bool {
        return redoList.count > 0
    }
    
    /// clear 가능 여부.
    var canClear: Bool {
        return canUndo || canRedo
    }
    
    /// undoManager가 가지고 있는 마지막 image를 반환한다.
    var lastImage: UIImage? {
        if let undoLast = undoList.last {
            return undoLast
        } else if let redoLast = redoList.last {
            return redoLast
        }
        return nil
    }
    
    /// undo 진행.
    func undo() {
        if let undoLast = undoList.last {
            appendRedo(undoLast)
            undoList.removeLast()
        }
    }
    
    /// redo 진행.
    func redo() {
        if let redoLast = redoList.last {
            appendUndo(redoLast)
            redoList.removeLast()
        }
    }
    
    /// clear 진행.
    func clear() {
        undoList.removeAll()
        redoList.removeAll()
    }
    
    /**
     Undo list에 해당 image를 추가한다.
     - parameter draw : 추가하려는 image.
     */
    func append(_ draw: UIImage?) {
        appendUndo(draw)
        redoList.removeAll()
    }
    
    private func appendUndo(_ draw: UIImage?) {
        guard let draw = draw else {return}
        if undoList.count >= maxSize {undoList.removeFirst()}
        undoList.append(draw)
    }
    
    private func appendRedo(_ draw: UIImage?) {
        guard let draw = draw else {return}
        if redoList.count >= maxSize {redoList.removeFirst()}
        redoList.append(draw)
    }
    
}

