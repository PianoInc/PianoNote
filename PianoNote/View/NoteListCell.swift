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
    
    @IBOutlet weak var innerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var innerViewLeadingConstraint: NSLayoutConstraint!
    
    var cellGestureRecognizer: NoteListGestureRecognizer?
    var startConstant: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.cornerRadius = 6
        innerView.layer.cornerRadius = 6
        pinButton.layer.cornerRadius = 6
        lockButton.layer.cornerRadius = 6
        trashButton.layer.cornerRadius = 6
        
        cellGestureRecognizer = NoteListGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        addGestureRecognizer(cellGestureRecognizer!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        innerViewLeadingConstraint.constant = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configure(isTop: Bool, isBottom: Bool) {
        
    }
    
    @IBAction func pinButtonTouched() {
    }

    @IBAction func lockButtonTouched() {
    }
    
    @IBAction func trashButtonTouched() {
    }
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
}

extension NoteListCell {
    @objc func didPan(sender: NoteListGestureRecognizer) {
        
        if sender.isActivated {
            if startConstant == nil {
                startConstant = innerViewLeadingConstraint.constant
            }
            
            innerViewLeadingConstraint.constant = startConstant! + sender.distance
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
}
