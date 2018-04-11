//
//  PianoTextEventCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import EventKit

class PianoTextEventCell: InteractiveAttachmentCell {
    
    @IBOutlet weak var startYearLabel: UILabel!
    @IBOutlet weak var endYearLabel: UILabel!
    @IBOutlet weak var startDayLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endDayLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    
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
        if case let .attachment(.event(eventAttribute)) = attribute.style {
            let components:Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]

            let startDateComponent = Calendar.current.dateComponents(components, from: eventAttribute.event.startDate)
            let endDateComponent = Calendar.current.dateComponents(components, from: eventAttribute.event.endDate)
            let currentYear = Calendar.current.dateComponents([.year], from: Date()).year!

            startYearLabel.text = String(startDateComponent.year!)
            endYearLabel.text = String(endDateComponent.year!)

            startYearLabel.isHidden = startDateComponent.year! == currentYear
            endYearLabel.isHidden = startDateComponent.year! == currentYear

            startDayLabel.text = String(format: "%02d월 %02d일", startDateComponent.month!, startDateComponent.day!)
            //TODO: I need to check the pattern of events. eg) isAllDay, hours or minutes == nil


        }
    }
}
