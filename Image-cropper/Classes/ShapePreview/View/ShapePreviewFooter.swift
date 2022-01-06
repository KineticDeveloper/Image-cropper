//
//  ShapePreviewFooter.swift
//  ios-app-milio
//
//  Created by VLC on 10/2/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import SnapKit
extension ShapePreviewFooter{
    public enum ButtonType: Int {
        case cropImage    = 101
        case addMoreImage = 102
    }
}
class ShapePreviewFooter: ShapePreviewBaseView {
    public weak var delegate: ShapePreviewFooterDelegate?
    
    public var editingTool        = UIStackView()
    public var btnScale           = UIImageView()
    public var btnAddImage        = UIImageView()
    
    override func setupComponent() {
        addSubview(editingTool)
        editingTool.axis         = .horizontal
        editingTool.spacing      = 8
        editingTool.distribution = .fill
        editingTool.addArrangedSubview(btnScale)
        btnScale.image = ICImageResourcePath("sp_scall")
        btnScale.tag = ShapePreviewFooter.ButtonType.cropImage.rawValue
        let tapBtnScale = UITapGestureRecognizer(target: self, action: #selector(didPressButton(_:)))
        btnScale.isUserInteractionEnabled = true
        btnScale.addGestureRecognizer(tapBtnScale)
        
        editingTool.addArrangedSubview(btnAddImage)
        btnAddImage.image = ICImageResourcePath("sp_add_image")
        btnAddImage.tag = ShapePreviewFooter.ButtonType.addMoreImage.rawValue
        let tapBtnAddImage = UITapGestureRecognizer(target: self, action: #selector(didPressButton(_:)))
        btnAddImage.isUserInteractionEnabled = true
        btnAddImage.addGestureRecognizer(tapBtnAddImage)
        
    }
    override func setupConstraint() {
        
        editingTool.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(11)
        }
        btnScale.snp.makeConstraints { (make) in
            make.height.width.equalTo(35)
        }
        btnAddImage.snp.makeConstraints { (make) in
            make.height.width.equalTo(35)
        }
    }
    
    @objc func didPressButton(_ sender: UITapGestureRecognizer){
        delegate?.didPressButton(didPressButton: sender)
    }

}
