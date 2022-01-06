//
//  MLOLibraryDelegate.swift
//  ios-app-milio
//
//  Created by VLC on 7/28/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit

public protocol MLOLibraryDelegate: AnyObject {
    func selectedPhoto(MilioPHAsset: [MilioPHAsset])
}

@objc
public protocol MilioPhotoPickerDelegate: AnyObject {
    
    @objc optional func milioPhotoPicker(selectedAssets: [MilioPHAsset])
    @objc optional func milioPhotoPickerCancel()
    @objc optional func milioPhotoPickerDismiss()
}
