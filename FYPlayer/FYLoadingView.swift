//
//  FYLoadingView.swift
//  Play
//
//  Created by 方圆 on 2017/8/9.
//  Copyright © 2017年 letus. All rights reserved.
//

import UIKit
import SnapKit

class FYLoadingView: UIView {

    let loadingImgView = UIImageView(image: UIImage(named:"loading_video_"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(loadingImgView)
        loadingImgView.snp.makeConstraints { (m) in
            m.width.height.equalTo(80)
            m.center.equalToSuperview()
        }
        setupLoadingAnimation()
    }
    
    func setupLoadingAnimation() {
        if loadingImgView.layer.animationKeys() != nil {
            return;
        }
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = Double.pi * 2
        rotateAnimation.duration = 1.0
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = "forwards"
        loadingImgView.layer.add(rotateAnimation, forKey: "rotation")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showAndStartAnimation() {
        if loadingImgView.layer.animationKeys() != nil {
            isHidden = false
            return
        }
        isHidden = false
        setupLoadingAnimation()
    }
    
    func hideAndStopAnimation() {
        if loadingImgView.layer.animationKeys() != nil {
            loadingImgView.layer.removeAllAnimations()
        }
        isHidden = true
    }

}
