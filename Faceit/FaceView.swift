//
//  FaceView.swift
//  Faceit
//
//  Created by 郭秭含 on 2017/5/31.
//  Copyright © 2017年 郭秭含. All rights reserved.
//

import UIKit

@IBDesignable

class FaceView: UIView {

    @IBInspectable
    var scale: CGFloat = 0.9
    
    @IBInspectable
    var eyesOpen: Bool = true
    
    @IBInspectable
    var mouthCurvature: Double = -0.5 // 1.0 is full smile and -1.0 is full frown
    
    @IBInspectable
    var lineWidth: CGFloat = 5.0
    
    @IBInspectable
    var color: UIColor = UIColor.blue
    
    private var skullRadius: CGFloat { // everytime you ask for it, it will be recomputed.
       return scale * min(bounds.size.width, bounds.size.height) / 2
    }
    
    private var skullCenter: CGPoint { // the reason why there's no set is that you can't set skull center. Skull center is defined by bounds. If you have only the get, turn out you don't need the 'get'.
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private func pathForSkull() -> UIBezierPath {
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0.0, endAngle: CGFloat(2.0*Double.pi), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    private enum Eye {
        case left
        case right
    }
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        let eyeCenter = centerOfEye(eye)
        let path: UIBezierPath
        if eyesOpen {
            path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)
        } else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        path.lineWidth = lineWidth
        return path
    }
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth / 2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        
        let controlPoint0 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileOffset)
        let controlPoint1 = CGPoint(x: end.x - mouthWidth / 3, y: start.y + smileOffset)
        
        // let path = UIBezierPath(rect: mouthRect)
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: controlPoint0, controlPoint2: controlPoint1)
        path.lineWidth = lineWidth
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        pathForSkull().stroke()
        pathForEye(.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
    
    private struct Ratios {
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }
}
