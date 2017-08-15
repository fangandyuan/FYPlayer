//
//  FYPlayerView.swift
//  Play
//
//  Created by 方圆 on 2017/8/10.
//  Copyright © 2017年 letus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import ReachabilitySwift
import IJKMediaFramework

@objc protocol FYPlayerViewDelegate : NSObjectProtocol {
    /*
     全屏按钮点击方法
     */
    @objc optional func fullTap()
    /*
     返回按钮点击方法
     */
    @objc func backTap()
}

class FYPlayerView: UIView {
    
    var ijkPlayer : IJKFFMoviePlayerController?
    var playerBaseView : UIView?
    var playerView : UIView?//播放器对应的View

    var toolsView : UIView?//播放器上的各种按钮
    var loadingView : FYLoadingView?//加载过程等待
    var playOptions: FYPlayerOption?

    
    var playBtn : UIButton?//播放
    //var lockBtn : UIButton?//锁屏
    var backBtn : UIButton?//返回
    var fullScreenBtn : UIButton?//全屏
    var currentLabel : UILabel?//当前播放时间
    var totalLabel : UILabel?//视频总时间
    var sliderView : UISlider?
    var progressView : UIProgressView?//

    //当前播放的url
    var playerUrl : String?
    var timer: Timer?//更新当前播放时间
    var baseViewTap: UITapGestureRecognizer?//点击屏幕
    
    //全屏
    let fullFrame = CGRect(x: 0, y: 0, width: FYScreenHeight, height: FYScreenWidth)
    var smallFrame: CGRect?
    var isFullScreen: Bool = false
    weak var parentView: UIView?

    var reachability : Reachability?
    
    weak var delegate : FYPlayerViewDelegate?
    
    
    init(frame: CGRect , urlStr : String, options: FYPlayerOption) {
        super.init(frame: frame)
        playerUrl = urlStr
        playOptions = options
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FYPlayerView.updateEvent), userInfo: nil, repeats: true)
        //
        setupPlayerBaseView()
        //创建播放器
        setupPlayerView()
        //创建播放器上的各种按钮
        setupToolsView()
        
        //创建等待
        setupLoadingView()
        showLoadingView()

        //添加ijkPlayer通知
        installMovieNotificationObservers()
        
        //自动播放
        ijkPlayer?.prepareToPlay()
        //先关闭tools
        hideTools()
        
        monitorNetwork()
    }
    
    //监听网络状态
    func monitorNetwork() {
        reachability = Reachability()!
        reachability?.whenReachable = { reachability in
            if reachability.isReachableViaWiFi {
                print("wifi")
                
            }else {
                print("WWAN")
            }
        }
        reachability?.whenUnreachable = { reachability in
            //
            print("没有网络")
        }
        
        do {
            try reachability?.startNotifier()
        }catch {
            print("Unable to start notifier")
        }

    }
    
    //更新方法(每秒钟执行一次)
    func updateEvent() {
        if ijkPlayer!.isPlaying() {
            playOptions?.currenTime = ijkPlayer!.currentPlaybackTime
            currentLabel?.text = TimeformatFromSeconds(secondes: Int(ijkPlayer!.currentPlaybackTime))
            let current = ijkPlayer!.currentPlaybackTime
            let total = ijkPlayer!.duration
            let able = ijkPlayer!.playableDuration
            sliderView?.setValue(Float(current/total), animated: true)
            progressView?.setProgress(Float(able/total), animated: true)
        }
    }
    
    func baseTap() {
        showTools()
        hideToolsAfter()
    }

    func setupPlayerBaseView() {
        backgroundColor = UIColor.black
        playerBaseView = UIView()
        playerBaseView?.frame = bounds
        insertSubview(playerBaseView!, at: 1)
        
        baseViewTap = UITapGestureRecognizer(target: self, action: #selector(FYPlayerView.baseTap))
        playerBaseView?.addGestureRecognizer(baseViewTap!)
    }
    
    
    
    func setupPlayerView() {
        let options = IJKFFOptions.byDefault()
        options?.setOptionIntValue(Int64(IJK_AVDISCARD_DEFAULT.rawValue), forKey: "skip_frame", of: kIJKFFOptionCategoryCodec)
        options?.setOptionIntValue(Int64(IJK_AVDISCARD_DEFAULT.rawValue), forKey: "skip_loop_filter", of: kIJKFFOptionCategoryCodec)
        options?.setOptionIntValue(0, forKey: "videotoolbox", of: kIJKFFOptionCategoryPlayer)
        options?.setOptionIntValue(60, forKey: "max-fps", of: kIJKFFOptionCategoryPlayer)
        options?.setPlayerOptionIntValue(256, forKey: "vol")
        
        let url = URL(string: playerUrl!)
        ijkPlayer = IJKFFMoviePlayerController(contentURL: url, with: options)
        ijkPlayer?.scalingMode = .aspectFill
        ijkPlayer?.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //设置视频缓存大小
        ijkPlayer?.setPlayerOptionIntValue(10 * 1024 * 1024, forKey: "max-buffer-size")
        
        playerView = ijkPlayer?.view
        playerView?.frame = bounds
        playerBaseView?.insertSubview(playerView!, at: 1)
    }
    
    
    func setupToolsView() {
        
        toolsView?.removeFromSuperview()
        toolsView = UIView(frame: bounds)
        toolsView?.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        playerBaseView?.insertSubview(toolsView!, at: 2)
        
        //在coverView上面添加返回按钮
        backBtn = UIButton()
        backBtn?.setImage(UIImage(named:"back"), for: .normal)
        toolsView?.addSubview(backBtn!)
        backBtn?.snp.makeConstraints({ (m) in
            m.left.equalTo(toolsView!)
            m.top.equalTo(toolsView!).offset(10)
            m.width.height.equalTo(40)
        })

        backBtn?.rx.tap.bind{ [weak self] in
            if (self?.isFullScreen)! {
                self?.fullTap()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self?.delegate?.backTap()
                })
            }else {
                self?.delegate?.backTap()

            }
        }.addDisposableTo(disposeBag)
        //在coverView上面添加全屏按钮
        fullScreenBtn = UIButton()
        fullScreenBtn?.setImage(UIImage(named:"fullScreen"), for: .normal)
        fullScreenBtn?.setImage(UIImage(named:"quiteScreen"), for: .selected)
        toolsView?.addSubview(fullScreenBtn!)
        fullScreenBtn?.snp.makeConstraints { (m) in
            m.bottom.right.equalTo(toolsView!)
            m.width.height.equalTo(50)
        }
        fullScreenBtn?.rx.tap.bind { [weak self] in
            self?.fullScreenBtn?.isSelected = !(self?.fullScreenBtn?.isSelected)!
            self?.fullTap()
            //self?.delegate?.fullTap!()
            }.addDisposableTo(disposeBag)
        
        //在coverView上面添加播放按钮
        playBtn = UIButton()
        playBtn?.setImage(UIImage(named:"pause"), for: .normal)
        playBtn?.setImage(UIImage(named:"play"), for: .selected)
        toolsView?.addSubview(playBtn!)
        playBtn?.snp.makeConstraints { (m) in
            m.center.equalTo(toolsView!)
            m.width.height.equalTo(100)
        }
        playBtn?.rx.tap.bind { [weak self] in
            if self?.playBtn != nil{
                self?.playBtn?.isSelected = !self!.playBtn!.isSelected
            }
            if self!.playBtn!.isSelected {
                self?.playOptions?.isPlaying = false
                self?.ijkPlayer?.pause()
            }else {
                self?.playOptions?.isPlaying = true
                self?.ijkPlayer?.play()
            }
            
            self?.hideToolsAfter()
            
            }.addDisposableTo(disposeBag)
        
        //在coverView上面添加锁定按钮
//        lockBtn = FYButton()
//        lockBtn?.setImage(UIImage(named:"lock1"), for: .normal)
//        lockBtn?.setImage(UIImage(named:"lockSel1"), for: .selected)
//        toolsView?.addSubview(lockBtn!)
//        lockBtn?.snp.makeConstraints { (m) in
//            m.centerY.equalTo(playBtn!)
//            m.left.equalTo(playBtn!)
//            m.width.height.equalTo(40)
//        }
        
        //在coverView上面添加视频当前时间Label
        currentLabel = UILabel()
        currentLabel?.font = UIFont.systemFont(ofSize: 15)
        if playOptions!.currenTime > TimeInterval(0) {
            currentLabel?.text = TimeformatFromSeconds(secondes: Int(playOptions!.currenTime))
        } else {
            currentLabel?.text = "00:00:00";
        }
        currentLabel?.textAlignment = .center
        currentLabel?.textColor = UIColor.white
        toolsView?.addSubview(currentLabel!)
        currentLabel?.snp.makeConstraints { (m) in
            m.left.equalTo(toolsView!).offset(10)
            m.centerY.equalTo(fullScreenBtn!)
            m.width.equalTo(65)
        }
        //在coverView上面添加视频总时长Label
        totalLabel = UILabel()
        totalLabel?.font = UIFont.systemFont(ofSize: 15)
        if playOptions!.totalTime > TimeInterval(0) {
            totalLabel?.text = TimeformatFromSeconds(secondes: Int(playOptions!.totalTime))
        }else {
            totalLabel?.text = "00:00:00";
        }
        totalLabel?.textAlignment = .right
        totalLabel?.textColor = UIColor.white
        toolsView?.addSubview(totalLabel!)
        totalLabel?.snp.makeConstraints { (m) in
            m.right.equalTo(fullScreenBtn!.snp.left)
            m.centerY.equalTo(fullScreenBtn!)
            m.width.equalTo(65);
        }
        
        
        //在coverView上面添加缓冲的进度条
        progressView = UIProgressView()
        toolsView?.addSubview(progressView!)
        progressView?.backgroundColor = UIColor.groupTableViewBackground
        progressView?.tintColor = UIColor.white
        progressView?.progress = 0.0
        progressView?.snp.makeConstraints { (m) in
            m.left.equalTo(currentLabel!.snp.right).offset(5)
            m.right.equalTo(totalLabel!.snp.left).offset(-5)
            m.centerY.equalTo(fullScreenBtn!)
        }
        
        //在coverView上面添加滑块
        sliderView = UISlider()
        toolsView?.addSubview(sliderView!)
        sliderView?.isUserInteractionEnabled = true
        sliderView?.isContinuous = false
        sliderView?.minimumTrackTintColor = UIColor.white
        sliderView?.maximumTrackTintColor = UIColor.clear
        sliderView?.minimumValue = 0
        sliderView?.maximumValue = 1.0
        sliderView?.snp.makeConstraints { (m) in
            m.left.right.width.equalTo(progressView!)
            m.centerY.equalTo(progressView!)
            m.height.equalTo(62)
        }
        sliderView?.addTarget(self, action: #selector(FYPlayerView.sliderTouchDownEvent(sender:)), for: .touchDown)
        sliderView?.addTarget(self, action: #selector(FYPlayerView.sliderValuechange(sender:)), for: .valueChanged)
        sliderView?.addTarget(self, action: #selector(FYPlayerView.sliderTouchUpEvent(sender:)), for: .touchUpInside)
        sliderView?.addTarget(self, action: #selector(FYPlayerView.sliderTouchUpEvent(sender:)), for: .touchUpOutside)
        
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func fullTap() {
        if self.isFullScreen {
            let frame = self.parentView?.convert(self.smallFrame!, to: UIApplication.shared.keyWindow)
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard self != nil  else {return}
                self?.transform = CGAffineTransform.identity
                self?.frame = frame!
            }, completion: { [weak self] (finished) in
                guard self != nil  else {return}
                self?.removeFromSuperview()
                self?.frame = self!.smallFrame!
                self?.parentView?.addSubview(self!)
                self?.isFullScreen = false
                UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portrait, animated: false)
            })
        }else {
            self.parentView = self.superview
            self.smallFrame = self.frame
            let rectInWindow = self.convert(self.frame, to: UIApplication.shared.keyWindow)
            self.removeFromSuperview()
            self.frame = rectInWindow
            UIApplication.shared.keyWindow?.addSubview(self)
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard self != nil  else {return}
                self?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.5))
                self?.bounds = self!.fullFrame
                self?.center = CGPoint(x: self!.superview!.bounds.midX, y: self!.superview!.bounds.midY)
            }, completion: { (finished) in
                self.isFullScreen = true
                UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.landscapeRight, animated: false)

            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerBaseView?.frame = bounds
        toolsView?.frame = bounds
        playerView?.frame = bounds
        loadingView?.frame = bounds
    }
    
    
    func setupLoadingView() {
        loadingView?.removeFromSuperview()
        loadingView = FYLoadingView(frame: bounds)
        playerBaseView?.insertSubview(loadingView!, at: 3)
    }
    
    func showTools() {
        toolsView?.alpha = 1.0
        toolsView?.isHidden = false
    }
    
    func hideTools() {
        toolsView?.alpha = 0.0
        toolsView?.isHidden = true

    }
    
    func hideToolsAfter() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FYPlayerView.hideToolsAnimate), object: nil)
        perform(#selector(FYPlayerView.hideToolsAnimate), with: nil, afterDelay: 5.0)
    }
    
    func hideToolsAnimate() {
        UIView.animate(withDuration: 1.5, animations: {
            self.toolsView?.alpha = 0.0
        }) { (finished) in
            self.toolsView?.isHidden = true
        }
    }
    
    //释放播放器
    func releasePlayer() {
        reachability?.stopNotifier()
        reachability = nil
        //移除通知
        removeMovieNotificationObservers()
        //移除定时器
        timer?.invalidate()
        timer = nil
        //移除播放器
        ijkPlayer?.stop()
        ijkPlayer?.shutdown()
        ijkPlayer = nil
        
        //移除baseView内部子控件
        for subView in playerBaseView!.subviews {
            subView.removeFromSuperview()
        }
        
        self.playerBaseView?.removeFromSuperview()
        self.playerBaseView = nil
    }
    
    
    //Mark: 把时间转成时分秒
    func TimeformatFromSeconds(secondes: Int) -> String {
        let hour = String(format: "%02ld", secondes/3600)
        let minute = String(format: "%02ld", (secondes % 3600) / 60)
        let second = String(format: "%02ld", secondes%60)
        return String(format: "%@:%@:%@", hour,minute,second)
    }
    
    //添加通知
    func installMovieNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(FYPlayerView.loadStateDidChange(notification:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(FYPlayerView.moviePlayBackFinish(notification:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(FYPlayerView.mediaIsPreparedToPlayDidChange(notification:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(FYPlayerView.mediaIsPreparedToPlayDidChange(notification:)), name: NSNotification.Name.IJKMPMoviePlayerIsAirPlayVideoActiveDidChange, object: ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(FYPlayerView.seekCompletedEvent), name: NSNotification.Name.IJKMPMoviePlayerDidSeekComplete, object: nil)
    }
    
    //移除通知
    func removeMovieNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: ijkPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: ijkPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: ijkPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerDidSeekComplete, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerIsAirPlayVideoActiveDidChange, object: ijkPlayer)
    }
    
    
    //更新加载状态
    func loadStateDidChange(notification : Notification) {
        let loadState = ijkPlayer!.loadState
        timer?.fire()
        
        if loadState.contains(IJKMPMovieLoadState.playthroughOK) {//播放
            NSLog("IJKMPMovieLoadState.playthroughOK")
            //缓存已经完成
            if ijkPlayer?.currentPlaybackTime == playOptions?.currenTime {
                //removeLoadingView()
            }
            if (ijkPlayer?.duration == 0.0) { //当前是直播
                progressView?.isHidden = true
                sliderView?.isHidden = true
                currentLabel?.isHidden = true
                totalLabel?.isHidden = true
            }
            showTools()
            hideToolsAfter()
            totalLabel?.text = TimeformatFromSeconds(secondes: Int(ijkPlayer!.duration))
            //playLoadStatesDelegate?.playerMPMovieLoadStatePlaythroughOK()
            
        }
        
        if loadState.contains(IJKMPMovieLoadState.stalled) {
            NSLog("IJKMPMovieLoadState.stalled")
            showLoadingView()
            hideTools()
            //playLoadStatesDelegate?.playerMPMovieLoadStateStalled()
        }
        
        if loadState.contains(IJKMPMovieLoadState.playable){
            NSLog("IJKMPMovieLoadState.playable")
            //playLoadStatesDelegate?.playerMPMovieLoadStatePlayable()
        }
    }
    
    
    //
    func seekCompletedEvent() {
        
    }
    //播放状态改变
    func moviePlayBackFinish(notification : Notification) {
        let reason : IJKMPMovieFinishReason = notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! IJKMPMovieFinishReason
        switch reason {
        case .playbackEnded:
            //playStatesDelegate?.playerMPMovieFinishReasonPlaybackEnded()
            break
        case .userExited:
            //playStatesDelegate?.playerMPMovieFinishReasonUserExited()
            break
        case .playbackError:
            //playStatesDelegate?.playerMPMovieFinishReasonPlaybackError()
            break
        }
    }
    //
    func recordThePropertiesOfThePlayer() {
        if playerBaseView != nil {
            playOptions?.currenTime = ijkPlayer!.currentPlaybackTime
            playOptions?.totalTime = ijkPlayer!.duration
            playOptions?.isPlaying = ijkPlayer!.isPlaying()
        }
    }
    
    func mediaIsPreparedToPlayDidChange(notification : Notification) {
        changeState()
    }
    
    
    //显示loading界面
    func showLoadingView() {
        loadingView?.showAndStartAnimation()
    }
    
    // 隐藏移除loading界面
    func removeLoadingView() {
        loadingView?.hideAndStopAnimation()
    }
    
    func changeState() {
        removeLoadingView()
        toolsView?.isHidden = false
        //toolsView?.isHidden = !toolsView!.isHidden
    }
    
    //
    func sliderTap(tap : UITapGestureRecognizer) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FYPlayerView.hideToolsAnimate), object: nil)
        let point = tap.location(in: sliderView)
        let value : Double = Double(point.x / sliderView!.bounds.size.width)
        updateSlider(sliderValue: value)
    }
    
    
    
    //滑块的touchDown方法
    func sliderTouchDownEvent(sender : UISlider) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FYPlayerView.hideToolsAnimate), object: nil)
        pause()
        print("sliderTouchDownEvent")

    }
    
    //滑块的touchUp方法
    func sliderTouchUpEvent(sender : UISlider) {
        print("sliderTouchUpEvent")
        let value : Double = Double(sender.value)
        updateSlider(sliderValue: value)
    }
    
    //滑块的值发生改变
    func sliderValuechange(sender : UISlider) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FYPlayerView.hideToolsAnimate), object: nil)
        NSLog("滑块的值发生了改变");
    }
    
    func updateSlider(sliderValue : Double) {
        var value = sliderValue * ijkPlayer!.duration
        if value == ijkPlayer!.duration && ijkPlayer!.duration > 5 {
            value = ijkPlayer!.duration - 5
        }else if value == ijkPlayer!.duration && ijkPlayer!.duration < 5 {
            value = ijkPlayer!.duration * 0.8
        }
        sliderView?.setValue(Float(sliderValue), animated: true)
        ijkPlayer?.currentPlaybackTime = value
        currentLabel?.text = TimeformatFromSeconds(secondes: Int(value))
        playOptions?.currenTime = value
        play()
        perform(#selector(FYPlayerView.hideToolsAnimate), with: nil, afterDelay: 4.0)
    }
    
    func play() {
        playOptions?.isPlaying = true
        self.playBtn?.isSelected = false
        ijkPlayer?.play()
    }
    
    func pause() {
        playOptions?.isPlaying = false
        playBtn?.isSelected = true
        ijkPlayer?.pause()
    }
    
}
