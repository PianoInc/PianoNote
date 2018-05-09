//
//  NoteLIstCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class NoteListCell: UITableViewCell {
    
    private let animationDuration = 0.2
    
    @IBOutlet weak var sectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sectionLabel: UILabel!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var pinImageView: UIImageView!
    
    @IBOutlet weak var largeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var innerViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var innerViewLeadingConstraint: NSLayoutConstraint!
    
    var cellGestureRecognizer: NoteListGestureRecognizer?
    weak var delegate: NoteListCellDelegate?
    private var startConstant: CGFloat?
    private var noteID: String?
    private var corners: UIRectCorner = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        innerView.layer.cornerRadius = 6
        pinButton.layer.cornerRadius = 6
        lockButton.layer.cornerRadius = 6
        trashButton.layer.cornerRadius = 6
        
        cellGestureRecognizer = NoteListGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        cellGestureRecognizer?.cancelsTouchesInView = false
        addGestureRecognizer(cellGestureRecognizer!)
        
        let tapGS = UITapGestureRecognizer(target: self, action: #selector(didTap))
        innerView.addGestureRecognizer(tapGS)
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIDeviceOrientationDidChange, object: nil, queue: nil) { [weak self](_) in
            //다른 오리엔테이션은 걸러라!
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
                || UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                self?.recalculateCorners()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        innerViewLeadingConstraint.constant = 6
        innerViewTopConstraint.constant = 6
        backView.layer.mask = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    private func recalculateCorners() {
        let maskPath = UIBezierPath(roundedRect: backView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 6, height: 6))
        
        let mask = CAShapeLayer()
        mask.path = maskPath.cgPath
        backView.layer.mask = mask
    }
    

    func configure(isTop: Bool, isBottom: Bool, currentModel: RealmNoteModel) {
        corners = []

        if isTop {
            corners.insert(.topLeft)
            corners.insert(.topRight)

            if currentModel.isPinned {
                sectionViewHeightConstraint.constant = 24
                sectionLabel.text = ""
            } else {
                sectionViewHeightConstraint.constant = 70
                sectionLabel.text = currentModel.isModified.timeFormat
            }
        } else {
            
            sectionViewHeightConstraint.constant = 0
            innerViewTopConstraint.constant = 0
            sectionLabel.text = ""
        }

        if isBottom {
            corners.insert(.bottomLeft)
            corners.insert(.bottomRight)
        }

        let maskPath = UIBezierPath(roundedRect: backView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 6, height: 6))
        let mask = CAShapeLayer()
        mask.path = maskPath.cgPath
        backView.layer.mask = mask

        largeLabel.text = currentModel.content
        largeLabel.text = largeLabel.firstLineText
        //Note: 이거 나중에 문제될거같다.... 200정도로 잘라주는게 좋을듯?
        contentLabel.text = currentModel.content.sub(largeLabel.firstLineText.count...)
        pinImageView.isHidden = !currentModel.isPinned

        noteID = currentModel.id

        self.layoutIfNeeded()
    }
    
    @IBAction func pinButtonTouched() {
        if let id = noteID {
            delegate?.requestPin(noteID: id)
        }
    }

    @IBAction func lockButtonTouched() {
        if let id = noteID {
            delegate?.requestLock(noteID: id)
        }
    }
    
    @IBAction func trashButtonTouched() {
        if let id = noteID {
            delegate?.requestDelete(noteID: id)
        }
    }

}

extension NoteListCell {

    func animateToDefault() {
        UIView.animate(withDuration: animationDuration) {
            self.innerViewLeadingConstraint.constant = 6.0
            self.layoutIfNeeded()
        }
    }

    func animateLeftOpen() {
        UIView.animate(withDuration: animationDuration) {
            self.innerViewLeadingConstraint.constant = 78.0
            self.layoutIfNeeded()
        }
    }

    func animateRightOpen() {
        UIView.animate(withDuration: animationDuration) {
            self.innerViewLeadingConstraint.constant = -150
            self.layoutIfNeeded()
        }
    }

    @objc func didPan(sender: NoteListGestureRecognizer) {
        
        if sender.isActivated {
            if startConstant == nil {
                startConstant = innerViewLeadingConstraint.constant
            }
            
            var distance = startConstant! + sender.distance
            
            if distance > 78 {
                distance = (distance - 78)/10 + 78
            } else if distance < -150 {
                distance = (150 + distance)/10 - 150
            }
            
            innerViewLeadingConstraint.constant = distance
            self.layoutIfNeeded()
        }
        if sender.state == .ended {
            startConstant = nil
            
            if innerViewLeadingConstraint.constant >= -75 && innerViewLeadingConstraint.constant <= 39 {
                animateToDefault()
            } else if innerViewLeadingConstraint.constant > 0 {
                animateLeftOpen()
            } else {
                animateRightOpen()
            }
        }
        
    }
    
    @objc func didTap() {
        if let id = noteID {
            delegate?.didTap(noteID: id)
        }
    }
}

protocol NoteListCellDelegate: class {
    func didTap(noteID: String)
    func requestDelete(noteID: String)
    func requestPin(noteID: String)
    func requestLock(noteID: String)
}
