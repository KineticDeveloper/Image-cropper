//
//  MilioLibraryVC.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit
import Photos
import SnapKit

public class MilioLibraryVC: MilioBaseVC {
    public weak var delegate: MilioPhotoPickerDelegate?
    /// Configure
    public var configure: MLOImagePickerConfiguration! {
        didSet{
            MLOImagePickerConfiguration.shared = configure
        }
    }
    /// get selectedAsset from user
    public var selectedAssets: [MilioPHAsset] = [] {
        didSet{
            isEnabledRightBarButtonItem(data: selectedAssets)
            
            milioLibrary.selectedAssets = selectedAssets
        }
    }
    /// Set title album of navigation bar
    fileprivate var titleAlbum: String = MLOConfig.library.titleAlbum{
        didSet{
            DispatchQueue.main.async {
                self.customTitleView.lbTitle.text = self.titleAlbum
            }
        }
    }
    /// Fetch result for display photos
    fileprivate var fetchResult: PHFetchResult<PHAsset>!{
        didSet{
            /// Prevent fetch result for display photos
            if titleAlbum != albumsManager.getTitleAlbum {
                /// Reset scroll to top
                if titleAlbum != MLOConfig.library.titleAlbum{
                    milioLibrary.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                              at: .top,
                                                              animated: false)
                }
                titleAlbum  = albumsManager.getTitleAlbum
                milioLibrary.fetchResult = fetchResult
            }
        }
    }
//    /// get selecteion when user  selectedAsset
//    fileprivate var selecteion: [MilioPHAsset] = [] {
//        didSet {
//            isEnabledRightBarButtonItem(data: selecteion)
//        }
//    }
    fileprivate let milioLibrary  = MilioLibraryView()
    fileprivate let albumsManager = MLOAlbumsManager()
    fileprivate var albums        = [MilioAlbum]()
    
    fileprivate var customTitleView = CustomTitleView()
    
    
    
    override func setupViewDidLoad() {
        checkAuthorization()
    }
    override func setupComponent() {
        setupNavigationView()
        view.addSubview(milioLibrary)
        milioLibrary.myDelegate = self
        
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.milioPhotoPickerDismiss?()
    }
    
    override func setupConstraint() {
        milioLibrary.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    fileprivate func fetchFistAlbum() {
        if albums.count == 0 {
            albumsManager.fetchAlbums { (albums) in
                if albums.count > 0 {
                    self.albums = albums
    //                let maxAlbumsNumberOfItems = self.albums.max { $0.numberOfItems < $1.numberOfItems }
                    self.albumsManager.loadAsset(album: albums[0]) { (fetch) in
                        self.fetchResult = fetch
                    }
                }
            }
        }
    }
}
/// Setup view and handle event
extension MilioLibraryVC{
    fileprivate func setupNavigationView(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(handleNext))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(cancel))
        isEnabledRightBarButtonItem(data: selectedAssets)
        setupTitle()
    }
    fileprivate func setupTitle() {
        customTitleView.isUserInteractionEnabled = true
        customTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickOnButton)))
        navigationItem.titleView = customTitleView
    }
    @objc fileprivate func clickOnButton(){
        let vc = MilioAlbumVC()
        vc.albums = albums
        vc.titleAlbum = titleAlbum
        vc.didSelectIndexAlbum = { selectedAlbum in
            self.albumsManager.loadAsset(album: self.albums[selectedAlbum]) { (fetch) in
                self.fetchResult = fetch
            }
        }
        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    @objc fileprivate func cancel(){
        delegate?.milioPhotoPickerCancel?()
        dismissVC()
    }
    @objc func handleNext(){
        delegate?.milioPhotoPicker?(selectedAssets: self.selectedAssets)
        dismissVC()
    }
    
    fileprivate func dismissVC(){
        
        DispatchQueue.main.async { [self] in
            dismiss(animated: true, completion: nil)
        }

    }
    
    fileprivate func isEnabledRightBarButtonItem(data: [MilioPHAsset]) {
        if data.count > 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

/// checkAuthorization
extension MilioLibraryVC{
    func checkAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    self?.fetchFistAlbum()
                default:
                    self?.dismissVC()
                }
            }
        case .authorized:
            self.fetchFistAlbum()
        case .restricted: fallthrough
        case .denied:
            self.handleNoAlbumPermissions()

        case .limited:
            break
        @unknown default:
            break
        }
    }
    func handleNoAlbumPermissions() {
        // handle denied albums permissions case
        let alert = UIAlertController(title: "This feature requires photo access",
                                      message: "Open iPhone Settings, tab Milio and turn on Photos.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Not Now",
                                      style: .cancel, handler: { (_) -> Void in
            self.dismissVC()
        }))
        alert.addAction(UIAlertAction(title: "Setting",
                                      style: .default,
                                      handler: { (_) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        self.present(alert,
                     animated: true,
                     completion: nil)
    }
}

extension MilioLibraryVC: MLOLibraryDelegate{
    public func selectedPhoto(MilioPHAsset: [MilioPHAsset]) {
        selectedAssets = MilioPHAsset
    }
}

class CustomTitleView: MilioBaseView {
    public var lbTitle     = UILabel()
    private var stackView  = UIStackView()
    private var lbSubTitle = UILabel()
    private var imageView  = UIImageView()
    override func setupComponent() {
//        backgroundColor = .red

        
        addSubview(lbTitle)
        lbTitle.text = "Camera Roll"
        lbTitle.textAlignment = .center
        lbTitle.textColor = .black
        lbTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4
        
        stackView.addArrangedSubview(lbSubTitle)
        lbSubTitle.text = "Tap here to change"
        lbSubTitle.textAlignment = .center
        lbSubTitle.textColor = .black
        lbSubTitle.font = .systemFont(ofSize: 12, weight: .regular)
        
        stackView.addArrangedSubview(imageView)
        let imageViewInsets = UIEdgeInsets(top: -4,left: -2, bottom: -2,right: -2)
        imageView.image = ICImageResourcePath("MLO_ImagePicker_Arrow")?.withAlignmentRectInsets(imageViewInsets)
        imageView.contentMode = .scaleAspectFill
        
    }
    override func setupConstraint() {
        
        lbTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(lbTitle.snp.bottom)
            make.centerX.equalTo(lbTitle.snp.centerX)
            make.bottom.equalToSuperview()
        }
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(15)
        }
    }
}

extension UIViewController{
   var navigationBarHeight: CGFloat {
       return self.navigationController?.navigationBar.frame.height ?? 0.0
   }
}
