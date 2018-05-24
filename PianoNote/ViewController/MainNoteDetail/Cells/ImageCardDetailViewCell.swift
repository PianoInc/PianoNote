//
//  ImageCardDetailViewCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 5. 24..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

class ImageCardDetailViewCell: UICollectionViewCell, Reusable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var livePhotoBadgeImageView: UIImageView!
    
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    var livePhotoBadgeImage: UIImage! {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImage = nil
        livePhotoBadgeImageView.image = nil
    }
}

protocol Reusable {}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
