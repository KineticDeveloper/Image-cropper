//
//  MilioFetchVM.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices


class MLOAlbumsManager {
    internal var fetchResult: PHFetchResult<PHAsset>!
    var titleAlbum: String = ""
    var getTitleAlbum: String {
        return titleAlbum
    }
    var albums = [MilioAlbum]()
    func fetchAlbums(getAlbums: @escaping ([MilioAlbum]) -> Void){
        
        //Camera Roll
        getSmartAlbum(subType: .smartAlbumUserLibrary)
        //Selfies
        getSmartAlbum(subType: .smartAlbumSelfPortraits)
        //Panoramas
        getSmartAlbum(subType: .smartAlbumPanoramas)
        //Favorites
        getSmartAlbum(subType: .smartAlbumFavorites)
        //Screenshots
        getSmartAlbum(subType: .smartAlbumScreenshots)
        //get all another albums
        getSmartAlbum(subType: .any, getAlbums: .album)
        
        if MLOConfig.library.mediaType == .photoAndVideo {
            //Videos
            getSmartAlbum(subType: .smartAlbumVideos)
        }
        // callBack
        getAlbums(albums)
    }
    func getSmartAlbum(subType: PHAssetCollectionSubtype, getAlbums: PHAssetCollectionType = .smartAlbum) {
        let options = PHFetchOptions()
        let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: getAlbums,
                                                                        subtype: subType,
                                                                        options: options)
        smartAlbumsResult.enumerateObjects({ assetCollection, _, _ in
            var album = MilioAlbum()
            album.title = assetCollection.localizedTitle ?? ""
            album.numberOfItems = self.mediaCountFor(collection: assetCollection)
            if album.numberOfItems > 0 {
                let r = PHAsset.fetchKeyAssets(in: assetCollection, options: nil)
                if let first = r?.firstObject {
                    let targetSize = CGSize(width: 80*2, height: 80*2)
                    MLOLibrary.shared.fetchImage(for: first, targetSize: targetSize) { (image) in
                        album.thumbnail = image
                    }
                }
                album.collection = assetCollection
                if MLOConfig.library.mediaType == .photo {
                    if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
                        || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                        self.albums.append(album)
                    }
                } else {
                    self.albums.append(album)
                }
            }
        })
    }
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func getPhotosFromAlbum(_ album: MilioAlbum ,PHFetchResult: @escaping (PHFetchResult<PHAsset>)-> Void){
        let option = buildPHFetchOptions()
        let collection = album.collection
        if let collection = collection {
            fetchResult = PHAsset.fetchAssets(in: collection, options: option)
        } else {
            fetchResult = PHAsset.fetchAssets(with: option)
        }
        PHFetchResult(fetchResult)
    }
    func loadAsset(album: MilioAlbum,fetchResult: @escaping (PHFetchResult<PHAsset>)-> Void) {
        self.getPhotosFromAlbum(album) { (PHFetchResult) in
            self.titleAlbum = album.title
            
            fetchResult(PHFetchResult)
        }
    }
    
    func buildPHFetchOptions() -> PHFetchOptions {
        // Sorting condition
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = MLOConfig.library.mediaType.predicate()
        return options
    }
    
    func mediaCountFor(collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        options.predicate = MLOConfig.library.mediaType.predicate()
        let result = PHAsset.fetchAssets(in: collection, options: options)
        return result.count
    }
    
    
}
extension MLOlibraryMediaType {
    
    func predicate() -> NSPredicate {
        switch self {
        case .photo:
            return NSPredicate(format: "mediaType = %d",
                               PHAssetMediaType.image.rawValue)
        case .video:
            return NSPredicate(format: "mediaType = %d",
                               PHAssetMediaType.video.rawValue)
        case .photoAndVideo:
            return NSPredicate(format: "mediaType = %d || mediaType = %d",
                               PHAssetMediaType.image.rawValue,
                               PHAssetMediaType.video.rawValue)
        }
    }
}

class MLOLibrary: NSObject{
    static let shared = MLOLibrary()
    func fetchImage(for asset: PHAsset,
                    targetSize: CGSize? = nil,
                    options: PHImageRequestOptions? = nil,
                    completion: @escaping ((UIImage?) -> Void)) {
        
        let target = targetSize == nil ? getTargetSize(asset: asset) : targetSize
        var options = options
        if options == nil {
            options = photoRequestOptions()
        }
        PHCachingImageManager.default().requestImage(
            for: asset,
            targetSize: target!,
            contentMode: .aspectFit,
            options: options,
            resultHandler: { (image, _) in
                completion(image)
        })
    }
    func fetchVideo(for asset: PHAsset,
                    completion: @escaping ((URL?) -> Void),
                    progress: ((Double) -> Void)? = nil) {
    
        let options = videoRequestOptions()
        
        options.progressHandler = {(progressFormCloud, error, stop, info) in
            progress?(progressFormCloud)
        }
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset, audioMix, info) in
            if let asset = asset as? AVURLAsset {
                completion(asset.url)
            }

        }
//        MLOLibrary.exportVideoFile(phAssets: asset,options: videoRequestOptions()) { (url, extType) in
//            print("url: =>",url)
//            completion(url)
//        }
    }
    static func exportVideoFile(phAssets: PHAsset?,
                                options: PHVideoRequestOptions? = nil,
                                outputURL: URL? = nil,
                                outputFileType: AVFileType = .mov,
                                progressBlock:((Double) -> Void)? = nil,
                                completionBlock:@escaping ((URL,String) -> Void)) {
        

        guard
            let phAsset = phAssets,
            phAsset.mediaType == .video,
            let writeURL = outputURL ?? videoFilename(phAsset: phAsset),
            let mimetype = MIMEType(writeURL)
            else {
                return
        }
        var requestOptions = PHVideoRequestOptions()
        if let options = options {
            requestOptions = options
        }else {
            requestOptions.isNetworkAccessAllowed = true
        }
        requestOptions.progressHandler = { (progress, error, stop, info) in
            DispatchQueue.main.async {
                progressBlock?(progress)
            }
        }
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: requestOptions) { (avasset, avaudioMix, infoDict) in
            guard let avasset = avasset else {
                return
            }
            let exportSession = AVAssetExportSession.init(asset: avasset, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.outputURL = writeURL
            exportSession?.outputFileType = outputFileType
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: avasset.duration)
            exportSession?.timeRange = range
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.exportAsynchronously(completionHandler: {
                completionBlock(writeURL, mimetype)
            })
        }
        
    }
    
    static func videoFilename(phAsset: PHAsset) -> URL? {
        guard let resource = (PHAssetResource.assetResources(for: phAsset).filter{ $0.type == .video }).first else {
            return nil
        }
        var writeURL: URL?
        let fileName = resource.originalFilename
        if #available(iOS 10.0, *) {
            writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        } else {
            writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(fileName)")
        }
        return writeURL
    }
    
    static func MIMEType(_ url: URL?) -> String? {
        guard let ext = url?.pathExtension else { return nil }
        if !ext.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag("public.filename-extension" as CFString, ext as CFString, nil)
            let UTI = UTIRef?.takeUnretainedValue()
            UTIRef?.release()
            if let UTI = UTI {
                guard let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) else { return nil }
                let MIMEType = MIMETypeRef.takeUnretainedValue()
                MIMETypeRef.release()
                return MIMEType as String
            }
        }
        return nil
    }
    
    func photoRequestOptions() -> PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .none
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        return options
    }
    
    func videoRequestOptions() -> PHVideoRequestOptions {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .mediumQualityFormat
        options.isNetworkAccessAllowed = true
        return options
    }
    func cellSize() -> CGSize {
        
        let size = (UIScreen.main.bounds.width/CGFloat(MLOConfig.library.numberOfItemsInRow))
        return CGSize(width: size, height: size)
    }
    func getTargetSize(asset: PHAsset) -> CGSize {
        return CGSize(width: CGFloat(asset.pixelWidth) * 0.5 , height: CGFloat(asset.pixelHeight) * 0.5)
    }
}


