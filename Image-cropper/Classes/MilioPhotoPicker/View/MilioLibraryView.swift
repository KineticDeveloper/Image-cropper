//
//  MilioLibraryView.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import Photos

fileprivate let milioLibraryCellId = "milioLibraryCellId"

class MilioLibraryView: MilioBaseView {
    internal var fetchResult: PHFetchResult<PHAsset>? {
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    weak var myDelegate: MLOLibraryDelegate?
    public var selectedAssets: [MilioPHAsset] = []
    override func setupComponent() {
        addSubview(collectionView)
        collectionView.backgroundColor = .clear
        
    }
    override func setupConstraint() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = true
        cv.register(MilioLibraryCell.self, forCellWithReuseIdentifier: milioLibraryCellId)
        return cv
    }()
}

extension MilioLibraryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
}
extension MilioLibraryView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margins = MLOConfig.library.spacingBetweenItems * CGFloat(MLOConfig.library.numberOfItemsInRow - 1)
        let width = (collectionView.frame.width - margins) / CGFloat(MLOConfig.library.numberOfItemsInRow)
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return MLOConfig.library.spacingBetweenItems
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return MLOConfig.library.spacingBetweenItems
    }
    
}
extension MilioLibraryView: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: milioLibraryCellId,
                                                      for: indexPath) as! MilioLibraryCell
        guard let getAsset = getMLOAsset(at: indexPath) else { return cell }
        let asset = getAsset.phAsset
        if let selectedAsset = getSelectedAssets(getAsset) {
            cell.selectedAsset = true
            cell.orderLabel.text = "\(selectedAsset.selectedOrder)"
        }else{
            cell.selectedAsset = false
        }
        cell.representedAssetIdentifier = asset?.localIdentifier
        if cell.representedAssetIdentifier == asset?.localIdentifier{
            MLOLibrary.shared.fetchImage(for: asset!,
                                         targetSize: MLOLibrary.shared.cellSize()) { (image) in
                                            // The cell may have been recycled when the time this gets called
                                            // set image only if it's still showing the same asset.
                                            if image != nil {
                                                cell.imageView.image = image
                                            }
            }
        }
        let isVideo = (asset?.mediaType == .video)
        cell.durationLabel.isHidden = !isVideo
        cell.durationLabel.text = isVideo ? MilioHelper.formattedStrigFrom(asset!.duration) : ""
        // Prevent weird animation where thumbnail fills cell on first scrolls.
        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? MilioLibraryCell else { return }
        toggleSelection(for: cell, at: indexPath)
    }
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            return self.previewImageView(indexPath: indexPath)
        }, actionProvider: nil)
    }
    func previewImageView(indexPath: IndexPath) -> UIViewController {
        let vc = UIViewController()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.isSynchronous = true // Ok since we're already in a background thread
        MLOLibrary.shared.fetchImage(for: (fetchResult?[indexPath.row])!,options: options) { (image) in
            if image != nil {
                imageView.image = image
                vc.preferredContentSize = image!.size
            }
        }
        vc.view = imageView
        return vc
    }
}
extension MilioLibraryView{
    func toggleSelection(for cell: MilioLibraryCell, at indexPath: IndexPath) {
        guard let asset = getMLOAsset(at: indexPath) else { return }
        cell.popScaleAnim()
        if let index = selectedAssets.firstIndex(where: { $0.phAsset == asset.phAsset }) {
            //deselect
            selectedAssets.remove(at: index)
            #if swift(>=4.1)
            selectedAssets = selectedAssets.enumerated().compactMap({ (offset,asset) -> MilioPHAsset? in
                let asset = asset
                asset.selectedOrder = offset + 1
                return asset
            })
            #else
            selectedAssets = selectedAssets.enumerated().flatMap({ (offset,asset) -> TLPHAsset? in
                var asset = asset
                asset.selectedOrder = offset + 1
                return asset
            })
            #endif
            cell.selectedAsset = false
            orderUpdateCells()
        } else {
            //select
            guard !maxCheck() else { return }
            
            asset.selectedOrder = selectedAssets.count + 1
            selectedAssets.append(asset)
            cell.selectedAsset = true
            cell.orderLabel.text = "\(asset.selectedOrder)"
        }
        myDelegate?.selectedPhoto(MilioPHAsset: selectedAssets)
    }
    func getMLOAsset(at indexPath: IndexPath) -> MilioPHAsset? {
        let index = indexPath.row
        guard let result = self.fetchResult, index < result.count else { return nil }
        return MilioPHAsset(asset: result.object(at: max(index,0)))
    }
    private func getSelectedAssets(_ asset: MilioPHAsset) -> MilioPHAsset? {
        if let index = self.selectedAssets.firstIndex(where: { $0.phAsset == asset.phAsset }) {
            return self.selectedAssets[index]
        }
        return nil
    }
    private func orderUpdateCells() {
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row })
        for indexPath in visibleIndexPaths {
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? MilioLibraryCell else { continue }
            guard let asset = self.getMLOAsset(at: indexPath) else { continue }
            if let selectedAsset = getSelectedAssets(asset) {
                cell.selectedAsset = true
                cell.orderLabel.text = "\(selectedAsset.selectedOrder)"
            }else {
                cell.selectedAsset = false
            }
        }
    }
    
    private func findIndexAndReloadCells(phAsset: PHAsset) {
        
        if let index = self.fetchResult?.index(of: phAsset){
            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    private func deselectWhenUsingSingleSelectedMode() {
        if
            MLOConfig.library.singleSelectedMode == true,
            let selectedPHAsset = self.selectedAssets.first?.phAsset
        {
            self.selectedAssets.removeAll()
            findIndexAndReloadCells(phAsset: selectedPHAsset)
        }
    }
    
    private func maxCheck() -> Bool {
        deselectWhenUsingSingleSelectedMode()
        if let max = MLOConfig.library.maxSelectedAssets, max <= self.selectedAssets.count {
            return true
        }
        return false
    }
}

