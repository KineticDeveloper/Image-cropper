//
//  ViewController.swift
//  Image-cropper
//
//  Created by 32827363 on 01/04/2022.
//  Copyright (c) 2022 32827363. All rights reserved.
//

import UIKit
import Image_cropper

class ViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var cloudDownloadProgress: CloudDownloadProgress!
    /// SelectedAssets
    public var selectedAssets: [MilioPHAsset] = []
    public var selectedAssetsAddMorePhoto: [MilioPHAsset] = []
    /// SelectedPhotos
    public var selectedPhotos: [SelectionPhoto] = []
    public var selectedAddMorePhoto: [SelectionPhoto] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .white
        
        view.addSubview(btnChoosePhoto)
        cloudDownloadProgress = CloudDownloadProgress(frame: appDelegate.window!.frame)
        btnChoosePhoto.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    lazy var btnChoosePhoto: UILabel = {
        let lb = UILabel()
        lb.text = "ChoosePhoto"
        lb.font = UIFont(name: "MarkerFelt-Thin", size: 30)
        lb.textColor = .red
        lb.textAlignment = .center
        lb.numberOfLines = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postChoosePhoto))
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(tapGesture)
        return lb
    }()
    
    
    /// Init data selected from imagePicker
    /// - Parameters:
    ///   - image: Image
    ///   - asset: Asset
    ///   - mediaType: MediaType
    ///   - completion: Completion
    
    /// PostChoosePhoto for MilioLibraryVC
    @objc func postChoosePhoto() {
        Spinner.start(style: .white, backgroundColor: UIColor.black.withAlphaComponent(0.5), touchHandler: nil)
        
        let selectedAssets = selectedAssetsAddMorePhoto.count == 0 ? self.selectedAssets : selectedAssetsAddMorePhoto
        let imagePicker                       = MilioLibraryVC()
        var configure                         = MLOImagePickerConfiguration()
        configure.library.spacingBetweenItems = 4.0
        configure.library.numberOfItemsInRow  = 3
        configure.library.maxSelectedAssets   = 10
        configure.library.mediaType           = .photoAndVideo
        imagePicker.configure                 = configure
        imagePicker.selectedAssets            = selectedAssets
        imagePicker.delegate                  = self
        let nav                    = UINavigationController(rootViewController: imagePicker)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true) {
            Spinner.stop()
        }
    }
    fileprivate func goToShapePreview() {
        let selectedPhotos = selectedAddMorePhoto.count == 0 ? self.selectedPhotos : selectedAddMorePhoto
        
        let vc = ShapePreviewVC(selectionPhoto: selectedPhotos)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true) {[self] in
            cloudDownloadProgress.stop()
        }
    }
    
    fileprivate func initDataSelectedPhotos(image: UIImage ,
                                            asset: MilioPHAsset,
                                            mediaType: ShapePreviewVC.MediaType,
                                            completion: @escaping ((SelectionPhoto) -> Void),
                                            progress: ((Double) -> Void)? = nil)
    {
        /// Check cache data strored or not
        var selectedPhotos = selectedAddMorePhoto.count == 0 ? self.selectedPhotos : selectedAddMorePhoto
        /// Chack already stored
        if let row = selectedPhotos.firstIndex(where: {$0.asset == asset.phAsset}) {
            selectedPhotos[row].index = asset.selectedOrder
            completion(selectedPhotos[row])
        }else{
            /// Create new data to strore
            let aspectRatio = selectedPhotos.count > 0 ? selectedPhotos[0].aspectRatio
            : AspectRatioResponse.init(width: 1, height: 1)
            
            var newObject = SelectionPhoto.init(index: asset.selectedOrder,
                                                originalImage: image,
                                                originalVideo: nil,
                                                mediaType: mediaType,
                                                asset: asset.phAsset,
                                                aspectRatio: aspectRatio,
                                                originalFileName: asset.originalFileName)
            /// Check mediaType
            switch mediaType {
            case .image:
                completion(newObject)
            case .video:
                /// Get video URL for imagePicker ( MP4 )
                asset.originalVideo { (res) in
                    newObject.originalVideo = res
                    completion(newObject)
                } progress: { (progressFromCloud) in
                    progress?(progressFromCloud)
                }
            }
        }
        
        
    }
    
    
    fileprivate func diffArrayObj() {
        for _ in self.selectedPhotos{
            if let index = self.selectedPhotos.firstIndex(where: { $0.isEdit == false }) {
                self.selectedPhotos.remove(at: index)
            }
        }
    }
    
}
/// get imagePicker
extension ViewController: MilioPhotoPickerDelegate {
    
    func milioPhotoPicker(selectedAssets: [MilioPHAsset]) {
        cloudDownloadProgress.start()
        if selectedAssetsAddMorePhoto.count == 0 { self.selectedAssets = selectedAssets }
        else { selectedAssetsAddMorePhoto = selectedAssets }
        var selection = [SelectionPhoto]()
        DispatchQueue.global(qos: .utility).async {[self] in
            let semaphore = DispatchSemaphore(value: 0) // initialize
            for (index, asset) in selectedAssets.enumerated(){
                cloudDownloadProgress.updateUIProcessing(currentIdex: index + 1, totalItems: selectedAssets.count)
                let type: ShapePreviewVC.MediaType = asset.type == .photo ? .image : .video
                asset.fullResolutionImage { (data) in
                    initDataSelectedPhotos(image: data!, asset: asset, mediaType: type) { (res) in
                        selection.append(res)
                        semaphore.signal() // continue the loop
                        
                    } progress: { (progress) in
                        let progress = Int(progress * 100)
                        cloudDownloadProgress.updateUIOfNumber(percentOfItem: progress)
                    }
                }
                
                semaphore.wait() // wait until func finished
            }
            // do something here when loop finished
            DispatchQueue.main.async {
                if self.selectedAddMorePhoto.count == 0 { self.selectedPhotos = selection }
                else { self.selectedAddMorePhoto = selection }
                self.goToShapePreview()
            }
        }
    }
    
    func milioPhotoPickerCancel() {
        ///
        self.selectedAssets             = self.selectedAssetsAddMorePhoto.count == 0 ? [] : self.selectedAssets
        self.selectedAssetsAddMorePhoto = self.selectedAssets
        ///
        self.selectedPhotos       = self.selectedAddMorePhoto.count == 0 ? [] : self.selectedPhotos
        self.selectedAddMorePhoto = self.selectedPhotos
    }
}


extension ViewController: ShapePreviewViewDelegate{
    /// ShapePreviewSelectedPhotos
    /// - Parameter selectedPhotos:Photos selected from shapePreview
    func shapePreviewSelectedPhotos(selectedPhotos: [SelectionPhoto]) {
        /// Overight selectedAssets
        if self.selectedAssetsAddMorePhoto.count == 0 { self.selectedAssetsAddMorePhoto = self.selectedAssets}
        else{ self.selectedAssets = self.selectedAssetsAddMorePhoto }
        
        self.diffArrayObj()
        /// Overight data selectionPhoto
        self.selectedPhotos.append(contentsOf: selectedPhotos)
        /// Overight selectedAddMorePhoto
        self.selectedAddMorePhoto          = self.selectedPhotos
        
        for selectedPhoto in self.selectedPhotos {
            print("selectedPhotos: =>", selectedPhoto.originalImage)
        }
       
    }
    /// ShapePreviewCancel
    /// - Parameter selectedPhotos: Photos selected from shapePreview
    func shapePreviewCancel(selectedPhotos: [SelectionPhoto]) {
        self.selectedAddMorePhoto = self.selectedAddMorePhoto.count == 0 ? [] : selectedPhotos
        DispatchQueue.main.async {
            self.postChoosePhoto()
        }
    }
    /// ShapePreviewAddMore
    /// - Parameter selectedPhotos: Photos selected from shapePreview
    func shapePreviewAddMore(selectedPhotos: [SelectionPhoto]) {
        self.selectedAddMorePhoto = self.selectedAddMorePhoto.count == 0 ? [] : selectedPhotos
        DispatchQueue.main.async {
            self.postChoosePhoto()
        }
    }
}



open class Spinner {
    internal static var spinnerView: UIActivityIndicatorView?
    
    public static var style: UIActivityIndicatorView.Style = .gray
    public static var backgroundColor: UIColor = UIColor(white: 0, alpha: 0.0)
    
    internal static var touchHandler: (() -> Void)?
    
    public static func start(style: UIActivityIndicatorView.Style = style, backgroundColor: UIColor = backgroundColor, touchHandler: (() -> Void)? = nil) {
        if spinnerView == nil,
            let window = UIApplication.shared.keyWindow {
            let frame = UIScreen.main.bounds
            spinnerView = UIActivityIndicatorView(frame: frame)
            spinnerView!.backgroundColor = backgroundColor
            spinnerView!.activityIndicatorViewStyle = style
            window.addSubview(spinnerView!)
            spinnerView!.startAnimating()
        }
        
        if touchHandler != nil {
            self.touchHandler = touchHandler
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(runTouchHandler))
            spinnerView!.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc internal static func runTouchHandler() {
        if touchHandler != nil {
            touchHandler!()
        }
    }
    
    public static func stop() {
        if let _ = spinnerView {
            spinnerView!.stopAnimating()
            spinnerView!.removeFromSuperview()
            spinnerView = nil
        }
    }
}



class CloudDownloadProgress: UIView {
    private var containView = UIView()
    private var spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    var lbProcessing: UILabel = {
        let lb = UILabel()
        lb.text = "Processing..."
        lb.font = .systemFont(ofSize: 16)
        lb.textColor = .white
        return lb
    }()
    var lbOfNumber: UILabel = {
        let lb = UILabel()
        lb.text = "_ of _"
        lb.font = .systemFont(ofSize: 14)
        lb.textColor = .white
        return lb
    }()
    
    func setupComponent() {
        addSubview(containView)
        containView.addSubview(spinnerView)
        spinnerView.startAnimating()
        
        containView.addSubview(lbProcessing)
        containView.addSubview(lbOfNumber)


        
    }
    func setupConstraint() {
        containView.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
        }
        
        spinnerView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.top.centerX.equalToSuperview()
        }
        
        lbProcessing.snp.makeConstraints { (make) in
            make.top.equalTo(spinnerView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        lbOfNumber.snp.makeConstraints { (make) in
            make.top.equalTo(lbProcessing.snp.bottom)
            make.centerX.bottom.equalToSuperview()
            
        }
        
    }
    func updateUIProcessing(currentIdex: Int, totalItems: Int) {
        DispatchQueue.main.async {[self] in
            lbOfNumber.text   = "\(currentIdex) of \(totalItems)"
        }
    }
    
    func updateUIOfNumber(percentOfItem: Int) {
        DispatchQueue.main.async {[self] in
            lbProcessing.text = "Proseccing \(percentOfItem)%"
        }
    }
    
    private func reset() {
        lbProcessing.text = "Proseccing..."
        lbOfNumber.text   = "_ of _"
    }
    
    
    func start() {
        if let window = UIApplication.shared.keyWindow {
            let frame = UIScreen.main.bounds
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.frame = frame
            window.addSubview(self)
            
            setupComponent()
            setupConstraint()
        }
    }
    
    func stop() {
        reset()
        spinnerView.stopAnimating()
        self.removeFromSuperview()
    }
}
