//
//  ViewController.swift
//  FYPlayer
//
//  Created by 方圆 on 2017/8/11.
//  Copyright © 2017年 fangyuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let playerVC = FYPlayerViewController()
        playerVC.playUrl =  "http://fastwebcache.yod.cn/yanglan/2013suoluosi/2013suoluosi_850/2013suoluosi_850.m3u8";
        playerVC.vidoeName = "杨澜采访索罗斯";
        self.navigationController?.pushViewController(playerVC, animated: true)

    }
    
    override var shouldAutorotate: Bool {
        return false
    }


}

