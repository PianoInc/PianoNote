//
//  PianoTextImageCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import RealmSwift

class PianoTextImageCell: InteractiveAttachmentCell, AttributeModelConfigurable {
    
    @IBOutlet weak var imageView: UIImageView!

    static let reuseIdentifier = "pianoImageCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    
    func configure(with id: String) {
        guard let realm = try? Realm(),
            let imageModel = realm.object(ofType: RealmImageModel.self, forPrimaryKey: id)
        else {return waitForReload(id: id)}
        
        guard let image = UIImage(data: imageModel.image) else {return}
        imageView.image = image
    }
    
    func waitForReload(id: String) {
        
    }
    
}
