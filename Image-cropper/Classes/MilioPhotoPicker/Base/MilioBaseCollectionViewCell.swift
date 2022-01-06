//
//  MilioBaseCollectionViewCell.swift
//  Image-cropper
//
//  Created by P-THY on 6/1/22.
//

import Foundation


class MilioBaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponent()
        setupConstraint()
        setupViewDidLoad()
    }
    func setupComponent() {}
    func setupConstraint() {}
    func setupViewDidLoad() {}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
