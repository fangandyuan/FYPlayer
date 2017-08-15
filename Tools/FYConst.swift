//
//  PConst.swift
//  Play
//
//  Created by 方圆 on 2017/3/8.
//  Copyright © 2017年 letus. All rights reserved.
//

import UIKit
import RxSwift

enum MovieDefinition {
    case height
    case general
    case low
}

public typealias Parameters = [String: Any]

 let FYRadius : CGFloat = 5;
 let FYSmallMarge : CGFloat = 10;
 let FYGeneralMarge : CGFloat = 15;
 let FYLargeMarge : CGFloat = 20;
 let FYNavHeight : CGFloat = 64;
 let FYTabBarHeight : CGFloat = 49;



let FYScreenWidth: CGFloat = UIScreen.main.bounds.width
let FYScreenHeight: CGFloat = UIScreen.main.bounds.height
let FYScreenScale = UIScreen.main.scale
let FYScreenWidthScale = UIScreen.main.bounds.width / 375.0


var disposeBag = DisposeBag()

extension Disposable {
    public func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}
