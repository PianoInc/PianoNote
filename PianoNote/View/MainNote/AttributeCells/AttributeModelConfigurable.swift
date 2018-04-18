//
// Created by 김범수 on 2018. 4. 10..
// Copyright (c) 2018 piano. All rights reserved.
//

import InteractiveTextEngine_iOS

protocol AttributeModelConfigurable {
    func configure(with attribute: AttachmentAttribute)
}

protocol AttributeContainingAttachment {
    var attribute: AttachmentAttribute! {get set}
}
