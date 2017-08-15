//
//  UITabBarControllerExtend.swift
//  FYPlayer
//
//  Created by 方圆 on 2017/8/14.
//  Copyright © 2017年 fangyuan. All rights reserved.
//

import UIKit


extension UITabBarController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let selectedVC = selectedViewController {
                return selectedVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            if let selectedVC = selectedViewController {
                return selectedVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            if let selectedVC = selectedViewController {
                return selectedVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }
}

