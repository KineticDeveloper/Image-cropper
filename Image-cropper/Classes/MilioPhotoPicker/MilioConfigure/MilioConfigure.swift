//
//  File.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import Foundation
import UIKit

/// Typealias for code prettiness
internal var MLOConfig: MLOImagePickerConfiguration { return MLOImagePickerConfiguration.shared }

public struct MLOImagePickerConfiguration {
    public static var shared: MLOImagePickerConfiguration = MLOImagePickerConfiguration()
    public init() {}
    // Library configuration
    public var library = MLOConfigLibrary()
    
}
/// Encapsulates library specific settings.
public struct MLOConfigLibrary {
    /// Choose what media types are available in the library. Defaults to `.photo`
    public var mediaType = MLOlibraryMediaType.photo
    /// Set the number of items per row in collection view. Defaults to 3.
    public var numberOfItemsInRow: Int = 3
    /// Set the spacing between items in collection view. Defaults to 2.0.
    public var spacingBetweenItems: CGFloat = 2.0
    /// Set the title album of navigation bar
    public var titleAlbum: String = "Loading..."
    /// SingleSelectedMode
    public var singleSelectedMode = false
    /// MaxSelectedAssets
    public var maxSelectedAssets: Int? = nil
}
public enum MLOlibraryMediaType {
    case photo
    case video
    case photoAndVideo
}
