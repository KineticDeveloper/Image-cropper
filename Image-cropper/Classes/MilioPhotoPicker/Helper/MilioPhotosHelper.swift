//
//  MilioPhotosHelper.swift
//  ios-app-milio
//
//  Created by VLC on 7/23/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//



import UIKit
import Photos

struct MilioHelper {
    
    static func formattedStrigFrom(_ timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
        let hours = interval / 3600
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        if hours != 0{
            return String(format: "%02d:%02d:%02d",hours, minutes, seconds)
        }else{
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    static func exportVideo(anAsset: AVURLAsset,
                            presetName: String = AVAssetExportPresetHighestQuality,
                            outputFileType: AVFileType = .mp4,
                            fileExtension: String = "mp4",
                            then completion: @escaping (URL?) -> Void)
    {
        let filename = anAsset.url.deletingPathExtension().appendingPathExtension(fileExtension).lastPathComponent
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        if let session = AVAssetExportSession(asset: anAsset, presetName: presetName) {
            session.outputURL = outputURL
            session.outputFileType = outputFileType
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: anAsset.duration)
            session.timeRange = range
            session.shouldOptimizeForNetworkUse = true
            session.exportAsynchronously {
                switch session.status {
                case .completed:
                    completion(outputURL)
                    _ = try? FileManager.default.removeItem(at: outputURL)
                case .cancelled:
                    debugPrint("Video export cancelled.")
                    completion(anAsset.url)
                case .failed:
                    let errorMessage = session.error?.localizedDescription ?? "n/a"
                    debugPrint("Video export failed with error: \(errorMessage)")
                    completion(anAsset.url)
                default:
                    break
                }
            }
        } else { completion(nil) }
    }
}

class PaddingLabel: UILabel {
    var topInset: CGFloat
    var bottomInset: CGFloat
    var leftInset: CGFloat
    var rightInset: CGFloat
    required init(withInsets top: CGFloat, _ bottom: CGFloat,_ left: CGFloat,_ right: CGFloat) {
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
        super.init(frame: CGRect.zero)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}
