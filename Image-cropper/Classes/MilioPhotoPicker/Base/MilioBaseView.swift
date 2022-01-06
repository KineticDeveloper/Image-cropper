//
//  MilioBaseView.swift
//  Image-cropper
//
//  Created by P-THY on 6/1/22.
//




import UIKit

class MilioBaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponent()
        setupConstraint()
        setupViewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupComponent() {}
    func setupConstraint() {}
    func setupViewDidLoad() {}
    
}
