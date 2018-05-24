//
//  PianoTextImageListCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import RealmSwift

class PianoTextImageListCell: InteractiveAttachmentCell {

    static let reuseIdentifier = "pianoImageListCell"
    
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var filterView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        firstImageView.image = nil
        secondImageView.image = nil
        thirdImageView.image = nil
    }
    
    
    func configure(with id: String) {
        guard let realm = try? Realm(),
            let imageModel = realm.object(ofType: RealmImageListModel.self, forPrimaryKey: id)
            else {return}
        
        let imageIDs = imageModel.imageIDs.components(separatedBy: "|")
        
        imageIDs[0..<3].forEach {
            if let imageModel = realm.object(ofType: RealmImageModel.self, forPrimaryKey: $0),
                let image = UIImage(data: imageModel.image) {
                self.fillImage(image: image)
            }
        }
        
        if imageIDs.count == 3 {
            filterView.isHidden = false
        } else if imageIDs.count > 3 {
            filterView.isHidden = true
        }
    }
    
    private func fillImage(image: UIImage) {
        if firstImageView.image == nil {
            firstImageView.image = image
        } else if secondImageView.image == nil {
            secondImageView.image = image
        } else if thirdImageView.image == nil {
            thirdImageView.image = image
        }
    }
    
    @IBAction func saveButtonTouched() {
    }
    
}
