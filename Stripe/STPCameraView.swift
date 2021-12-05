//
//  STPCameraView.swift
//  Stripe
//
//  Created by David Estes on 8/17/20.
//  Copyright © 2020 Stripe, Inc. All rights reserved.
//

import AVFoundation
import UIKit

@available(macCatalyst 14.0, *)
class STPCameraView: UIView {
    
    private var flashLayer: CALayer?
    
    /*
        这种写法很普遍. 这个 View, 就是为了使得 Layer 纳入到 View 的体系里面.
     */
    var captureSession: AVCaptureSession? {
        get {
            return (videoPreviewLayer.session)!
        }
        set(captureSession) {
            videoPreviewLayer.session = captureSession
        }
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    func playSnapshotAnimation() {
        CATransaction.begin()
        // 设置了 CATransaction 的这个值, 就能让后面对于 Layer 属性设置的隐式动画消失.
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        flashLayer?.frame = CGRect(
            x: 0, y: 0, width: layer.bounds.size.width, height: layer.bounds.size.height)
        flashLayer?.opacity = 1.0
        CATransaction.commit()
        
        // 在前面, 重置了 Layer 的属性之后, 才进行真正的动画的编写.
        DispatchQueue.main.async(execute: {
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.fromValue = NSNumber(value: 1.0)
            fadeAnim.toValue = NSNumber(value: 0.0)
            fadeAnim.duration = 1.0
            self.flashLayer?.add(fadeAnim, forKey: "opacity")
            self.flashLayer?.opacity = 0.0
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        flashLayer = CALayer()
        if let flashLayer = flashLayer {
            layer.addSublayer(flashLayer)
        }
        flashLayer?.masksToBounds = true
        flashLayer?.backgroundColor = UIColor.black.cgColor
        flashLayer?.opacity = 0.0
        layer.masksToBounds = true
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 1
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
