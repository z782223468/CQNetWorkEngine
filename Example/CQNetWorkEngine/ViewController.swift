//
//  ViewController.swift
//  CQNetWorkEngine
//
//  Created by 782223468@qq.com on 05/16/2019.
//  Copyright (c) 2019 782223468@qq.com. All rights reserved.
//

import UIKit
import CQNetWorkEngine
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headers: HTTPHeaders = ["userId":"5aeac90546a2bc54a457ee17","version":"1.3.29"]
        
        NetworkEngine.getInstance().headers = headers
        
        let dic = NSMutableDictionary()
        dic["passive"] = "5aeac90546a2bc54a457ee17"
    NetworkEngine.getInstance().asynchronousPostRequestWithUrl("http://performance.jsxywg.cn/node/performance/app/checkPerformance/findByUserId", withDataDic: dic, withSuccess: { (returnData) in
        
            print(returnData)
            
        }) { (errorString) in
            print(errorString)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

