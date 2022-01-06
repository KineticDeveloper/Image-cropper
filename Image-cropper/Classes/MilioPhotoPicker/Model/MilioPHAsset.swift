//
//  MilioPHAsset.swift
//  ios-app-milio
//
//  Created by VLC on 7/24/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import Photos
import UIKit

public class MilioPHAsset: NSObject {
    
    public enum AssetType {
        case photo, video
    }
    public var phAsset: PHAsset? = nil
    public var selectedOrder: Int = 0
    public var type: AssetType {
        get {
            guard let phAsset = self.phAsset else { return .photo }
            if phAsset.mediaType == .video {
                return .video
            }else {
                return .photo
            }
        }
    }
    public var originalFileName: String? {
        get {
            if type == .photo {
                guard let phAsset = self.phAsset,let resource = PHAssetResource.assetResources(for: phAsset).first else { return nil }
                return resource.originalFilename
            }else {
                guard let phAsset = self.phAsset, let resource = (PHAssetResource.assetResources(for: phAsset).filter{ $0.type == .video }).first else {
                    return nil
                }
                return resource.originalFilename
            }

        }
    }
    
    public func fullResolutionImage( completion: @escaping ((UIImage?) -> Void)) {
        guard let phAsset = self.phAsset else { return }
        MLOLibrary.shared.fetchImage(for: phAsset) { (data) in
            completion(data)
        }
    }
    public func originalVideo(completion: @escaping ((URL?) -> Void), progress: ((Double) -> Void)? = nil ) {
        guard let phAsset = self.phAsset else { return }
        MLOLibrary.shared.fetchVideo(for: phAsset) { (data) in
            completion(data)
            
        } progress: { (progressFromCloud) in
            progress?(progressFromCloud)
        }

    }
    public init(asset: PHAsset?) {
        self.phAsset = asset
    }
}
