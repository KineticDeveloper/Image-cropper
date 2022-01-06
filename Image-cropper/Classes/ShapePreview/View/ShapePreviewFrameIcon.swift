//
//  ShapePreviewFrameIcon.swift
//  ios-app-milio
//
//  Created by VLC on 10/12/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit

private var selectionFramCellId = "selectionFramCellId"
class ShapePreviewFrameIcon: ShapePreviewBaseView {
    public weak var delegate: ShapePreviewFrameIconDelegate?

    public var selectionFrame = [UIImage]()
    public var icon: [ShapePreviewFrameIconModel] = []
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ShapePreviewFrameIconCell.self, forCellWithReuseIdentifier: selectionFramCellId)
        return cv
    }()
    override func setupViewDidLoad() {
        let portrait = ShapePreviewFrameIconModel(type: "Portrait", icon: "sp_portrait_4_6", aspectRatio: AspectRatioResponse(width: 4, height: 6))
        let landscape = ShapePreviewFrameIconModel(type: "Landscape", icon: "sp_lanscape_6_4", aspectRatio: AspectRatioResponse(width: 6, height: 4))
        let square = ShapePreviewFrameIconModel(type: "Square", icon: "sp_square_1_1", aspectRatio: AspectRatioResponse(width: 1, height: 1))
        icon = [portrait,landscape,square]
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    override func setupComponent() {
        addSubview(collectionView)
        
    }
    override func setupConstraint() {
        collectionView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}
extension ShapePreviewFrameIcon: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectionFramCellId, for: indexPath) as! ShapePreviewFrameIconCell
        cell.imageView.image = ICImageResourcePath(icon[indexPath.row].icon)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 35, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectionFrame(selectionFrame: icon[indexPath.row])
        
    }
    
}
class ShapePreviewFrameIconCell: UICollectionViewCell {
    
    public var imageView = UIImageView()
    public var removePhoto = UIButton()
    public var width:NSLayoutConstraint?
    public var height:NSLayoutConstraint?
    lazy var icVideoPlay: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.image = ICImageResourcePath("ic_video_play")
        imageView.isHidden = true
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.isUserInteractionEnabled = false
        backgroundColor = .clear
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor(hexString: "#ff6d00").cgColor
        addSubview(imageView)
        
        addSubview(removePhoto)
        removePhoto.isHidden = true
        removePhoto.backgroundColor = UIColor(hexString: "#343432")
        removePhoto.layer.masksToBounds = true
        removePhoto.layer.cornerRadius = 35 / 2
        removePhoto.setImage(ICImageResourcePath("sp_remove"), for: .normal)
        removePhoto.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        removePhoto.translatesAutoresizingMaskIntoConstraints = false
        removePhoto.widthAnchor.constraint(equalToConstant: 35.0).isActive = true
        removePhoto.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        removePhoto.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        removePhoto.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        addSubview(icVideoPlay)
        icVideoPlay.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        icVideoPlay.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        width = icVideoPlay.heightAnchor.constraint(equalToConstant: 50)
        width?.isActive = true
        height = icVideoPlay.widthAnchor.constraint(equalToConstant: 50)
        height?.isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public struct ShapePreviewFrameIconModel{
    let type: String
    let icon: String
    let aspectRatio: AspectRatioResponse
}
