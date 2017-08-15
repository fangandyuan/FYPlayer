//
//  FYPlayerOption.swift
//  Play
//
//  Created by 方圆 on 2017/8/9.
//  Copyright © 2017年 letus. All rights reserved.
//

import UIKit

class FYPlayerOption: NSObject {

    //屏幕方向
    var interfaceOrientation : UIDeviceOrientation?
    //是否播放
    var isPlaying : Bool = false
    //当前播放时间
    var currenTime : TimeInterval = 0
    //视频总的播放时间
    var totalTime : TimeInterval = 0
    //视频是不是第一响应者
    var isBeingActiveState : Bool = false
    // 当前播放器处于被显示状态
    var isBeingAppearState : Bool = false
}
