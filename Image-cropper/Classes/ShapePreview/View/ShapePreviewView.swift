//
//  ShapePreviewView.swift
//  ios-app-milio
//
//  Created by VLC on 10/2/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import SnapKit

class ShapePreviewView: UIView {
    // MARK: - Internal views
    lazy var headerView: ShapePreviewHeader = { [unowned self] in
        let view             = ShapePreviewHeader()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.delegate        = self
        return view
        }()
    
    lazy var footerView: ShapePreviewFooter = { [unowned self] in
        let view             = ShapePreviewFooter()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.delegate        = self
        return view
    }()
    
    lazy var selectFrameIcon: ShapePreviewFrameIcon = { [unowned self] in
        let view             = ShapePreviewFrameIcon()
        view.backgroundColor = .clear
        view.delegate        = self
        view.isHidden        = true
        return view
    }()
    
    lazy var shapePreview: ShapePreviewSelectionPhotos = { [unowned self] in
        let view             = ShapePreviewSelectionPhotos(selectionPhoto: selectionPhoto)
        view.delegate        = self
        view.shapePreviewVC  = self
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Properties
    public weak var delegate: ShapePreviewZoomingDelegate?
    public var shapePreviewVC: ShapePreviewVC?
    
    let baseHeight: CGFloat = 60.0
    var image: UIImage!
    var imageView: UIImageView!
    var scrollView = UIScrollView()
    private var circleView: ShapePreviewFrame!
    private var contentFrame = CGRect.zero
    
    var selectionPhoto: [SelectionPhoto]
    var selectedPhoto: SelectionPhoto?
    var currentSelectedOfIndex: Int = 0
    // MARK: - init view

    public init(selectionPhoto: [SelectionPhoto],contentFrame: CGRect) {
        self.selectionPhoto = selectionPhoto
        self.contentFrame = contentFrame
//        imageView = UIImageView(image: image)
        circleView = ShapePreviewFrame(frame: contentFrame)
        super.init(frame: CGRect.zero)
        
        addSubview(scrollView)
        addSubview(circleView)

        scrollView.maximumZoomScale = 1.0
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = self.contentFrame
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        if #available(iOS 11, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        setupComponent()
        setupConstraint()
        
        isShowBtnScale()
       
    }
    // MARK: - configureLayout
    public func configureLayout(selection: SelectionPhoto) {
        self.selectedPhoto = selection
        /// setup images
        setupImage(originalImage: selection.originalImage!)
        /// update UI
        updateUI(aspectRatio: selection.aspectRatio!)
        
        
    }
    private func setupImage(originalImage: UIImage){
        self.image = originalImage
        imageView = UIImageView(image: image)
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        scrollView.addSubview(imageView)
    }
    
    public func updateUI(aspectRatio: AspectRatioResponse) {
        
        let scrollFrame = scrollView.frame
        let imSize = image.size
        circleView.aspectRatio = aspectRatio
        centerImageView()
        guard let hole = circleView?.circleInset, hole.width > 0 else { return }
        let verticalRatio = hole.height / imSize.height
        let horizontalRatio = hole.width / imSize.width
        let maxScale = max(verticalRatio, horizontalRatio)
        
        scrollView.minimumZoomScale = maxScale
        scrollView.zoomScale = selectedPhoto?.updatedCrop == true ? selectedPhoto?.scrollViewZoomScale ?? 0.0 : maxScale
        
        let insetHeight = (scrollFrame.height - hole.height) / 2
        let insetWidth = (scrollFrame.width - hole.width) / 2
        scrollView.contentInset = UIEdgeInsets(top: insetHeight, left: insetWidth, bottom: insetHeight, right: insetWidth)
        scrollView.contentOffset = setContentOffset()
        
    }
    
    func setContentOffset() -> CGPoint {
        if selectedPhoto?.updatedCrop == true{
            return selectedPhoto?.scrollViewContentOffset ?? CGPoint(x: 0, y: 0)
        }
        let view = self.scrollView
        let scrollCenterX = (view.contentSize.width - view.frame.width) / 2
        let scrollCenterY = (view.contentSize.height - view.frame.height) / 2
        return CGPoint(x: scrollCenterX, y: scrollCenterY)
    }
  
    func centerImageView() {
        guard let boundsSize = circleView?.circleInset, boundsSize.width > 0 else { return }
        var imageViewFrame = imageView.frame
        if imageViewFrame.size.width < boundsSize.width {
            imageViewFrame.origin.x = (boundsSize.width - imageViewFrame.size.width) / 2.0
        } else {
            imageViewFrame.origin.x = 0.0
        }
        
        if imageViewFrame.size.height < boundsSize.height {
            imageViewFrame.origin.y = (boundsSize.height - imageViewFrame.size.height) / 2.0
        } else {
            imageViewFrame.origin.y = 0.0
        }
        
        imageView.frame.origin = imageViewFrame.origin
    }
    // MARK: - Recognizers
    
    @objc func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: imageView)
        let newZoomScale = scrollView.zoomScale > scrollView.minimumZoomScale
            ? scrollView.minimumZoomScale
            : scrollView.maximumZoomScale
        
        let width = contentFrame.size.width / newZoomScale
        let height = contentFrame.size.height / newZoomScale
        let x = pointInView.x - (width / 2.0)
        let y = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: width, height: height)
        
        scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    // MARK: - setup setupComponents
    
    func setupComponent() {
        backgroundColor = .clear
        [headerView, footerView, shapePreview, selectFrameIcon].forEach{ addSubview($0) }
    }
    func setupConstraint() {
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(baseHeight + 44)
        }
        
        footerView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(baseHeight + 44)
        }
        selectFrameIcon.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.height.equalTo(125)
            make.centerX.equalTo(footerView.btnScale.snp.centerX)
            make.bottom.equalTo(footerView.btnScale.snp.top)
        }
        
        shapePreview.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.width.equalTo(UIScreen.main.bounds.width - 64)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top).offset( -5)
        }
    }
    
    public func cropImage( success: @escaping (UIImage) -> Void){
        guard let rect = self.circleView?.circleInset else { return }
        let shift = rect.applying(
            CGAffineTransform(
                translationX: self.scrollView.contentOffset.x,
                y: self.scrollView.contentOffset.y
            )
        )
        let scaled = shift.applying(
            CGAffineTransform(
                scaleX: 1.0 / self.scrollView.zoomScale,
                y: 1.0 / self.scrollView.zoomScale
            )
        )
        let newImage = self.image.imageCropped(toRect: scaled)
        success(newImage)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - setup UIScrollViewDelegate
extension ShapePreviewView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.scrollViewDidEndZooming(shapePreviewView: self,currentlySelectedIndex: self.currentSelectedOfIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndZooming(shapePreviewView: self, currentlySelectedIndex: self.currentSelectedOfIndex)
    }
}
// MARK: - setup ShapePreviewSelectionPhotosDelegate

extension ShapePreviewView: ShapePreviewSelectionPhotosDelegate {
    
    func didSelect(shapePreviewSelection: ShapePreviewSelectionPhotos, currentIndex: Int) {
        currentSelectedOfIndex = currentIndex
        configureLayout(selection: selectionPhoto[currentIndex])
        
        
        if currentIndex != 0  && selectFrameIcon.isHidden == false { isShowSelectFrame() }
        isShowBtnScale()
    }
    
    func isShowBtnScale() {
//        let isEditPost = MLORequestUpload.createPostVM?.objectForUpload.isEditPost ?? false
        let currentIndex: Int = currentSelectedOfIndex
//        if isEditPost { currentIndex = 1 }
        footerView.btnScale.alpha = currentIndex != 0 ? 0.5 : 1.0
        footerView.btnScale.isUserInteractionEnabled = currentIndex != 0 ? false : true
    }
}

// MARK: - setup ShapePreviewHeaderDelegate
extension ShapePreviewView: ShapePreviewHeaderDelegate {
    
    func didPressButton(didPressButton sender: UIButton) {
        shapePreviewVC?.didPressButton(didPressButton: sender)
    }
    
}
// MARK: - setup ShapePreviewFooterDelegate
extension ShapePreviewView: ShapePreviewFooterDelegate {
    func didPressButton(didPressButton sender: UITapGestureRecognizer) {
        shapePreviewVC?.didPressButton(shapePreviewView: self, didPressButton: sender)
    }
    
    func isShowSelectFrame() {
        selectFrameIcon.isHidden = selectFrameIcon.isHidden ? false : true
    }
}

// MARK: - setup ShapePreviewFrameIconDelegate
extension ShapePreviewView: ShapePreviewFrameIconDelegate {
    func selectionFrame(selectionFrame: ShapePreviewFrameIconModel) {
        shapePreviewVC?.chooseFrameIcon(
            shapePreviewView: self,
            selectionFrame: selectionFrame,
            currentSelectedOfIndex: self.currentSelectedOfIndex
        )
    }
}

