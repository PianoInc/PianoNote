//
//  PianoTextLinkCell.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 9..
//  Copyright © 2018년 piano. All rights reserved.
//

import InteractiveTextEngine_iOS
import URLEmbeddedView


class PianoTextLinkCell: InteractiveAttachmentCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlImageView: URLImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var uuid: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor(hex6: "E9E9E9").cgColor
        layer.cornerRadius = 10.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelLoad()
        titleLabel.text = nil
        urlImageView.image = nil
    }
    
    func cancelLoad() {
        activityIndicator.stopAnimating()
        urlImageView.cancelLoadImage()
        guard let uuid = uuid else {return}
        OGDataProvider.shared.cancelLoad(uuid, stopTask: true)
    }
    
    func configure(with attribute: AttachmentAttribute) {
        if case let .link(linkAttribute) = attribute {
            urlLabel.text = linkAttribute.link
            activityIndicator.startAnimating()
            uuid = OGDataProvider.shared.fetchOGData(urlString: linkAttribute.link, completion: { [weak self] (ogData, error) in
                self?.activityIndicator.stopAnimating()
                if let imageURL = ogData.imageUrl {
                    self?.urlImageView.loadImage(urlString: imageURL.absoluteString)
                }
                if let title = ogData.pageTitle {
                    self?.titleLabel.text = title
                }
            })
        }
    }
}
