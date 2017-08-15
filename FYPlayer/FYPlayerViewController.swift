//
//  PlayerViewController.swift
//  FYPlayer
//
//  Created by 方圆 on 2017/8/11.
//  Copyright © 2017年 fangyuan. All rights reserved.
//

import UIKit

class FYPlayerViewController: UIViewController , FYPlayerViewDelegate {

    var playUrl : String?
    var vidoeName : String?
    var playerView : FYPlayerView?
    var timer : Timer?
    var nextBtn : UIButton?
    var options : FYPlayerOption?
    var netShowView : FYNetNotiView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        options = FYPlayerOption()
        options?.isPlaying = true
        options?.isBeingActiveState = true
        options?.isBeingAppearState = true
        options?.interfaceOrientation = UIDevice.current.orientation
        let frame = CGRect(x: 0, y: 0, width: FYScreenWidth, height: 200);
        playerView = FYPlayerView(frame: frame,urlStr: playUrl!, options: options!)
        playerView?.delegate = self as FYPlayerViewDelegate
        view.addSubview(playerView!)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(FYPlayerViewController.backTap))
        
        
        
    }
    

    

    
    //释放播放器以及所有的子控件
    func releasePlayerView() {
        playerView?.releasePlayer()
        playerView?.removeFromSuperview()
        playerView = nil
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        super.viewWillAppear(animated)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.allowRotation = true
        options?.isBeingAppearState = false;
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.allowRotation = false
        options?.isBeingAppearState = true;
        
       releasePlayerView()


    }
    
    func backTap() {//返回
        if self.navigationController != nil {
            navigationController?.popViewController(animated: true)
        }else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
