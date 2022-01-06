//
//  MilioAlbumCell.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit

class MilioAlbumCell: MilioBaseTableViewCell {

    let thumbnail = UIImageView()
    let title = UILabel()
    let numberOfItems = UILabel()
    let stackView = UIStackView()
    override func setupComponent() {
        addSubview(thumbnail)
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        thumbnail.clipsToBounds = true
        
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(numberOfItems)
        
        title.font = .systemFont(ofSize: 16)
        numberOfItems.font = .systemFont(ofSize: 12)
        
    }
    override func setupConstraint() {
        thumbnail.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-6)
            make.height.width.equalTo(78)
        }
        stackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(thumbnail.snp.centerY)
            make.left.equalTo(thumbnail.snp.right).offset(16)
        }
    }
}
