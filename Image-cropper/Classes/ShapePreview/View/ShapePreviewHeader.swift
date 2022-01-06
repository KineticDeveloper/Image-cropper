//
//  ShapePreviewHeader.swift
//  ios-app-milio
//
//  Created by VLC on 10/2/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import SnapKit
extension ShapePreviewHeader{
    public enum ButtonType: Int {
        case back = 101
        case done = 102
    }
}

class ShapePreviewHeader: ShapePreviewBaseView {
    weak var delegate: ShapePreviewHeaderDelegate?
    lazy var btnBack: UIButton = {
        let b = UIButton()
        b.setImage(ICImageResourcePath("sp_back"), for: .normal)
        b.tag = ShapePreviewHeader.ButtonType.back.rawValue
        b.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        return b
    }()
    lazy var btnFinish: UIButton = {
        let b = UIButton()
        b.setTitle("Done", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16)
        b.layer.masksToBounds = true
        b.layer.cornerRadius = 6
        b.backgroundColor = .white
        b.tag = ShapePreviewHeader.ButtonType.done.rawValue
        b.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        return b
    }()
    lazy var lbTitle: UILabel = {
        let b = UILabel()
        b.textColor = .white
        b.text = "Shape Preview"
        b.font = .systemFont(ofSize: 16)
        b.textAlignment = .center
        b.numberOfLines = 0
        return b
    }()
    
    
    override func setupComponent() {
        [btnBack, lbTitle, btnFinish].forEach{ addSubview($0) }
        
    }
    override func setupConstraint() {
        btnBack.snp.makeConstraints { (make) in
            make.width.height.equalTo(35)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(11)
        }
        
        lbTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(btnBack.snp.centerY)
        }
        btnFinish.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-11)
            make.height.equalTo(30)
            make.width.equalTo(60)
            make.centerY.equalTo(btnBack.snp.centerY)
        }
    }
    @objc func didPressButton(_ sender: UIButton) {
        delegate?.didPressButton(didPressButton: sender)
    }
}
