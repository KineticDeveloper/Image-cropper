//
//  ShapePreviewSelectionPhotos.swift
//  ios-app-milio
//
//  Created by VLC on 10/7/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
public var selectionPhotoCellId = "selectionPhotoCellId"
class ShapePreviewSelectionPhotos: UIView {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = true
        cv.register(CreatePostPreviewPhotosCell.self, forCellWithReuseIdentifier: selectionPhotoCellId)
        return cv
    }()
    weak var delegate: ShapePreviewSelectionPhotosDelegate?
    var selectionPhoto: [SelectionPhoto] = []
    public weak var shapePreviewVC: ShapePreviewView?
    public init(selectionPhoto: [SelectionPhoto]) {
        self.selectionPhoto = selectionPhoto
        super.init(frame: CGRect.zero)
        
        addSubview(collectionView)
        collectionView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
extension ShapePreviewSelectionPhotos: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectionPhoto.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectionPhotoCellId, for: indexPath) as! CreatePostPreviewPhotosCell
        cell.imageView.image = selectionPhoto[indexPath.row].originalImage
        if indexPath.row == shapePreviewVC?.currentSelectedOfIndex{
            cell.imageView.layer.borderWidth = 2
        }else{
            cell.imageView.layer.borderWidth = 0
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(shapePreviewSelection: self, currentIndex: indexPath.row)
        collectionView.reloadData()
    }
}



class CreatePostPreviewPhotosCell: ShapePreviewBaseCollectionViewCell {
    
    public var ivVideo = UIImageView()
    public var imageView = UIImageView()
    override func setupComponent() {
        addSubview(imageView)
        imageView.autoresizingMask    = [.flexibleHeight,.flexibleWidth]
        imageView.contentMode         = .scaleAspectFill
        imageView.clipsToBounds       = true
        imageView.layer.borderColor   = UIColor.orange.cgColor
        imageView.layer.borderWidth   = 0
        imageView.layer.masksToBounds = true
        
        
        addSubview(ivVideo)
        ivVideo.contentMode      = .scaleAspectFill
        ivVideo.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ivVideo.clipsToBounds    = true
        ivVideo.image            = ICImageResourcePath("video_play_icon")
        ivVideo.isHidden         = true
    }
    
    override func setupConstraint() {
        imageView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        ivVideo.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
}

