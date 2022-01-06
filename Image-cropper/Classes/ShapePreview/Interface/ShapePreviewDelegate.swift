//
//  ShapePreviewDelegate.swift
//  ios-app-milio
//
//  Created by VLC on 10/2/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import Photos

protocol ShapePreviewHeaderDelegate: AnyObject {
    func didPressButton(didPressButton sender: UIButton)
}

protocol ShapePreviewFooterDelegate: AnyObject {
    func didPressButton(didPressButton sender: UITapGestureRecognizer)
}
protocol ShapePreviewFrameIconDelegate: AnyObject {
    func selectionFrame(selectionFrame: ShapePreviewFrameIconModel)
    
}

protocol ShapePreviewZoomingDelegate: AnyObject {
    func scrollViewDidEndZooming(shapePreviewView view: ShapePreviewView, currentlySelectedIndex currentIndex: Int)
    
}

protocol ShapePreviewSelectionPhotosDelegate: AnyObject {
    func didSelect(shapePreviewSelection: ShapePreviewSelectionPhotos ,currentIndex: Int)
}


public protocol ShapePreviewViewDelegate: AnyObject {
    func shapePreviewSelectedPhotos(selectedPhotos: [SelectionPhoto])
    func shapePreviewCancel(selectedPhotos: [SelectionPhoto])
    func shapePreviewAddMore( selectedPhotos: [SelectionPhoto])
}


public struct SelectionPhoto {
    public var index: Int
    public var originalImage: UIImage?
    public var modifiedImage: UIImage?
    public var originalVideo: URL?
    public var mediaType: ShapePreviewVC.MediaType
    public var updatedCrop: Bool
    public var asset: PHAsset?
    public var scrollViewContentOffset: CGPoint?
    public var scrollViewZoomScale: CGFloat?
    public var aspectRatio: AspectRatioResponse?
    public var accessURL: String?
    public var isEdit: Bool
    public var mediaId: String?
    public var originalFileName: String?
    
    public init(
        index: Int = 0,
        originalImage: UIImage? = nil,
        modifiedImage: UIImage? = nil,
        originalVideo: URL? = nil,
        mediaType: ShapePreviewVC.MediaType = .image,
        updatedCrop: Bool = false,
        asset: PHAsset? = nil,
        scrollViewContentOffset: CGPoint? = nil,
        scrollViewZoomScale: CGFloat? = nil,
        aspectRatio: AspectRatioResponse? = nil,
        accessURL: String? = nil,
        isEdit: Bool = false,
        mediaId: String? = nil,
        originalFileName: String? = nil
    ) {
        
        self.index = index
        self.originalImage = originalImage
        self.modifiedImage = modifiedImage
        self.originalVideo = originalVideo
        self.mediaType = mediaType
        self.updatedCrop = updatedCrop
        self.asset = asset
        self.scrollViewContentOffset = scrollViewContentOffset
        self.scrollViewZoomScale = scrollViewZoomScale
        self.aspectRatio = aspectRatio
        self.accessURL = accessURL
        self.isEdit = isEdit
        self.mediaId = mediaId
        self.originalFileName = originalFileName
        
    }
    
    
}

extension ShapePreviewVC {
    public enum MediaType: String,Codable {
        case image = "image"
        case video = "video"
    }
}

public struct AspectRatioResponse: Codable {
    public let width: Double
    public let height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}


