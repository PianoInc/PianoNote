//
//  PianoTextReminderCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

class PianoTextReminderCell: InteractiveAttachmentCell {
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var largeTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor(hex6: "E9E9E9").cgColor
        layer.cornerRadius = 10.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with attribute: AttributeModel) {
        if case let .attachment(.reminder(reminderAttribute)) = attribute.style {
            if let dueDate = reminderAttribute.reminder.dueDateComponents {
                titleLabel.isHidden = false
                dueDateLabel.isHidden = false
                largeTitleLabel.isHidden = true
                titleLabel.text = reminderAttribute.reminder.title

                //TODO:get text from component
                dueDateLabel.text = ""
            } else {
                titleLabel.isHidden = true
                dueDateLabel.isHidden = true
                largeTitleLabel.isHidden = false
                largeTitleLabel.text = reminderAttribute.reminder.title
            }

            //TODO: fix names
            let imageName = reminderAttribute.reminder.isCompleted ? "imageBoxChecked" : "imageBoxUnChecked"
            checkBoxImageView.image = UIImage(named: imageName)
        }
    }
}
