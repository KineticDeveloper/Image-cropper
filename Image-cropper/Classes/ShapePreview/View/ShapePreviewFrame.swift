//
//  ShapePreviewFrame.swift
//  ios-app-milio
//
//  Created by VLC on 10/6/20.
//  Copyright © 2020 Core-MVVM. All rights reserved.
//

import UIKit

public class ShapePreviewFrame: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.58)
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var aspectRatio: AspectRatioResponse = AspectRatioResponse(width: 1, height: 1){
        didSet{
            setNeedsDisplay()
        }
    }
    var circleInset: CGRect {
        let rect = bounds
        let height = CalculateHeightAspectRatio.sharedInstance.getHeight(screenWidth: UIScreen.main.bounds.width,
                                                                         aspectRatio: aspectRatio)
        let hole = CGRect(x: 0,
                          y: (rect.height - height) / 2,
                          width: rect.width,
                          height: height).insetBy(dx: 0, dy: 0)
        return hole
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let holeInset = circleInset
        context.addRect(holeInset)
        context.clip()
        context.clear(holeInset)
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(holeInset)
        context.setStrokeColor(UIColor.white.cgColor)
        context.stroke(holeInset, width: 3.0)
        context.restoreGState()
    }
}
