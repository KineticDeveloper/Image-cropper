//
//  Milio.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//


import UIKit
import Photos

struct MilioAlbum {
    var thumbnail: UIImage?
    var title: String = ""
    var numberOfItems: Int = 0
    var collection: PHAssetCollection?
}
