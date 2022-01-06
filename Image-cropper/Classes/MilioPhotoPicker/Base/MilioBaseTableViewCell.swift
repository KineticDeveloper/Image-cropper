//
//  MilioBaseTableViewCell.swift
//  Image-cropper
//
//  Created by P-THY on 6/1/22.
//


import UIKit
class MilioBaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupComponent()
        setupConstraint()
        setupViewDidLoad()
    }
    func setupComponent() {}
    func setupConstraint() {}
    func setupViewDidLoad() {}
    
    /// To get height of UILabel
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
       label.numberOfLines = 0
       label.lineBreakMode = NSLineBreakMode.byWordWrapping
       label.font = font
       label.text = text

       label.sizeToFit()
       return label.frame.height
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
