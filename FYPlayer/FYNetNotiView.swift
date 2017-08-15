//
//  FYNetNotiView.swift
//  Play
//
//  Created by 方圆 on 2017/8/9.
//  Copyright © 2017年 letus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
enum FYNetWortType {
    case Wifi
    case WWAN  //3G/4G网络
    case NoNetWork
}

class FYNetNotiView: UIView {

    //网络状态
    var networkType : FYNetWortType = .Wifi
    
    let bgView : UIView = UIView()
    let showLabel : UILabel = UILabel()
    let selectBtn : UIButton = UIButton()
    var selectTap:(() -> Void)?

    //返回按钮
    let backBtn : UIButton = UIButton()
    var backTap:(() -> Void)?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgView.backgroundColor = UIColor.black
        addSubview(bgView)

        showLabel.textAlignment = .center
        showLabel.font = UIFont.systemFont(ofSize: 14 * FYScreenScale)
        showLabel.textColor = UIColor.white
        addSubview(showLabel)

        selectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        selectBtn.layer.cornerRadius = 30 * FYScreenScale
        selectBtn.layer.masksToBounds = true
        selectBtn.layer.borderColor = UIColor.red.cgColor
        selectBtn.layer.borderWidth = 1
        selectBtn.rx.tap.bind { [weak self] in //点击事件
            if self?.selectTap != nil {
                self?.selectTap!()
            }
        }.addDisposableTo(disposeBag)
        addSubview(selectBtn)
        
        backBtn.setTitle("返回", for: .normal)
        backBtn.rx.tap.bind { [weak self] in //点击事件
            if self?.backTap != nil {
                self?.backTap!()
            }
        }.addDisposableTo(disposeBag)
        addSubview(backBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = bounds
        showLabel.frame = CGRect(x: 0, y: bounds.height * 0.5 - 59 * FYScreenScale, width: bounds.width, height: 28 * FYScreenScale)
        selectBtn.frame = CGRect(x: bounds.width - 100 * FYScreenScale, y: bounds.height * 0.5 + 17 * FYScreenScale, width: 200 * FYScreenScale, height: 60 * FYScreenScale)
        backBtn.frame = CGRect(x: 0, y: 40 * FYScreenScale, width: 120 * FYScreenScale, height: 60 * FYScreenScale)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func contentWithNoNetWork() {
        self.networkType = .NoNetWork
        self.showLabel.text = "请确认网络连接后再重试"
        selectBtn.setTitle("点击重试", for: .normal)
        
    }
    
    func contentWithWWAN() {
        self.networkType = .WWAN
        self.showLabel.text = "当前是3/4G流量"
        selectBtn.setTitle("继续播放", for: .normal)
    }
    
    
    func showNetNotiView(networkType : FYNetWortType) {
        switch networkType {
        case .Wifi:
            hidNetNotiView()
            break
        case .NoNetWork:
            contentWithNoNetWork()
        break
        case .WWAN:
            contentWithWWAN()
        break
        }
    }
    
    func hidNetNotiView() {
        self.isHidden = true
    }
    
}
