//
//  EffectCollectionViewCell.swift
//  quickstart-ios-swift
//
//  Created by Pavel Sakhanko on 02/02/2021.
//  Copyright © 2021 Ivan Gulidov. All rights reserved.
//

import UIKit

class EffectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var onReuse: () -> Void = {}

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        previewImage.image = nil
    }

}
