//
//  MilioLibraryCell.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import SnapKit
class MilioLibraryCell: MilioBaseCollectionViewCell {
    var representedAssetIdentifier: String!
    let imageView = UIImageView()
    let iconImageView = UIImageView()
    let durationLabel = UILabel()
    let selectionOverlay = UIView()
    let orderLabel = PaddingLabel(withInsets: 8, 8, 13, 13)
    override func setupComponent() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.clipsToBounds = true
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor(red: 88/255, green: 144/255, blue: 255/255, alpha: 1.0).cgColor
        
        addSubview(durationLabel)
        durationLabel.textColor = .white
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.isHidden = true
        
        addSubview(orderLabel)
        orderLabel.textColor = .white
        orderLabel.backgroundColor = UIColor(red: 88/255, green: 144/255, blue: 255/255, alpha: 1.0)
        orderLabel.font = .systemFont(ofSize: 14)
        orderLabel.isHidden = true
        
        addSubview(selectionOverlay)
        selectionOverlay.backgroundColor = .white
        selectionOverlay.alpha = 0
        
    }
    override func setupConstraint() {
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        selectionOverlay.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        durationLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        orderLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    @objc open var selectedAsset: Bool = false {
        willSet(newValue) {
            if !newValue {
                self.orderLabel.isHidden = true
                imageView.layer.borderWidth = 0
                self.orderLabel.text = ""
            }else{
                self.orderLabel.isHidden = false
                imageView.layer.borderWidth = 4
            }
        }
    }
    @objc open func popScaleAnim() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    override var isSelected: Bool {
        didSet { isHighlighted = isSelected }
    }
    
    override var isHighlighted: Bool {
        didSet {
            selectionOverlay.alpha = isHighlighted ? 0.2 : 0
        }
    }
}
