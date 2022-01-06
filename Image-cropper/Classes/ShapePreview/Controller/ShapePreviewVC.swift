//
//  ShapePreviewVC.swift
//  ios-app-milio
//
//  Created by VLC on 10/2/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit

public class ShapePreviewVC: ShapePreviewBaseVC {
    public weak var delegate: ShapePreviewViewDelegate?
    var shapePreviewView: ShapePreviewView!
    var selectionPhotos: [SelectionPhoto] = []
    // MARK: - Properties
    var statusBarState = false
    
    public init(selectionPhoto: [SelectionPhoto]) {
        self.selectionPhotos = selectionPhoto
        super.init(nibName: nil, bundle: nil)
        self.diffArrayObj()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - View lifecycle
    
    public override var prefersStatusBarHidden: Bool{
        return statusBarState
    }    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStatusBar(show: true)
    }
    
    override func setupComponent() {
        shapePreviewView = ShapePreviewView(selectionPhoto: selectionPhotos, contentFrame: self.view.bounds)
        shapePreviewView.delegate = self
        shapePreviewView.shapePreviewVC = self
        view.backgroundColor = .black
        view.addSubview(shapePreviewView)
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.shapePreviewView.frame = self.view.bounds
        self.shapePreviewView.configureLayout(selection: selectionPhotos[0])
    }
}
extension ShapePreviewVC{
    /// setupStatusBar
    func setupStatusBar(show: Bool = true) {
        statusBarState = show
        UIView.animate(withDuration: show ? 0.5 : 0.0) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    func diffArrayObj() {
        if self.selectionPhotos[0].isEdit == true {
            for _ in self.selectionPhotos{
                if let index = self.selectionPhotos.firstIndex(where: { $0.isEdit == true }) {
                    self.selectionPhotos.remove(at: index)
                }
            }
        }
    }
}

extension ShapePreviewVC {
    /// Header
    /// - Parameter sender: handle didPressButton
    func didPressButton(didPressButton sender: UIButton) {
        let group = DispatchGroup() // initialize
        if let action = ShapePreviewHeader.ButtonType(rawValue: sender.tag) {
            switch action {
            case .back:
                /// back to prarent
                delegate?.shapePreviewCancel(selectedPhotos: self.selectionPhotos)
                self.dismiss(animated: true, completion: nil)
            case .done:
                /// fished crop
                for (index, item) in selectionPhotos.enumerated() {
                    group.enter() // wait
                    if item.updatedCrop == false && item.modifiedImage == nil{
                        ///
                        self.shapePreviewView.configureLayout(selection: item)
                        ///
                        shapePreviewView.cropImage { (newImage) in
                            ///
                            self.selectionPhotos[index].modifiedImage = newImage
                            group.leave() // continue the loop
                        }
                    }else{ group.leave() } // continue the loop
                }
                // do something here when loop finished
                group.notify(queue: .main) {
                    ///
                    self.delegate?.shapePreviewSelectedPhotos(selectedPhotos: self.selectionPhotos)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    /// Footer
    /// - Parameters:
    ///   - view: ShapePreviewView
    ///   - sender: handle didPressButton
    func didPressButton( shapePreviewView view: ShapePreviewView, didPressButton sender: UITapGestureRecognizer) {
        
        if let action = ShapePreviewFooter.ButtonType(rawValue: sender.view!.tag) {
            switch action {
            case .cropImage:
                view.isShowSelectFrame()
            case .addMoreImage:
                delegate?.shapePreviewAddMore(selectedPhotos: self.selectionPhotos)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// ChooseFrameIcon
    /// - Parameters:
    ///   - view: ShapePreviewView
    ///   - selectionFrame: get frame when seleced icon frame
    ///   - currentIdex: currentIdex of photo seleced
    func chooseFrameIcon(shapePreviewView view: ShapePreviewView,
                         selectionFrame: ShapePreviewFrameIconModel,
                         currentSelectedOfIndex currentIdex: Int)
    {
        /// Reset data
        for (index,_) in selectionPhotos.enumerated(){
            selectionPhotos[index].scrollViewContentOffset = nil
            selectionPhotos[index].scrollViewZoomScale = nil
            selectionPhotos[index].modifiedImage = nil
            selectionPhotos[index].updatedCrop = false
            selectionPhotos[index].aspectRatio = selectionFrame.aspectRatio
        }
        view.selectionPhoto = selectionPhotos
        view.selectedPhoto = selectionPhotos[currentIdex]
        view.updateUI(aspectRatio: selectionFrame.aspectRatio)
    }
}
// MARK: - setup ShapePreviewZoomingDelegate
extension ShapePreviewVC: ShapePreviewZoomingDelegate{
    
    /// update and auto crop image
    func scrollViewDidEndZooming(shapePreviewView view: ShapePreviewView, currentlySelectedIndex currentIndex: Int) {
        selectionPhotos[currentIndex].updatedCrop = true
        selectionPhotos[currentIndex].scrollViewContentOffset = view.scrollView.contentOffset
        selectionPhotos[currentIndex].scrollViewZoomScale = view.scrollView.zoomScale
        shapePreviewView.cropImage { (newImage) in
            self.selectionPhotos[currentIndex].modifiedImage = newImage
        }
        view.selectionPhoto = selectionPhotos
    }
}




