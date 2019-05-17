//
//  NetworkEngine.swift
//  ProjectDemo
//
//  Created by retygu on 15/11/27.
//  Copyright © 2015年 retygu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KKProgressToolbar

public typealias requestSuccessClosureToOC = (_ obj:JSON)->Void
public typealias requestSuccessClosure = (_ obj:JSON)->Void
public typealias requestFailedClosure = (_ errorString:String)->Void

let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

public class NetworkEngine: NSObject, KKProgressToolbarDelegate {
    // 单例创建
    fileprivate static let networkEngine: NetworkEngine = NetworkEngine()
    
    public class func getInstance() -> NetworkEngine {
        return networkEngine
    }
    // 重写init让其成为私有的，防止其他对象使用这个类的默认的‘()‘初始化方法来创建对象
    // 确保NetworkEngine()编译不通过
    fileprivate override init() {}
    
    var statusToolbar = KKProgressToolbar()
    var timer: Timer? // 显示文件下载进度定时器
    var statusLabelString = "" // 下载进度
    var downloadRequest: DownloadRequest?
    
    
    public var headers: HTTPHeaders!       //配置header
    
    
    /**
     系统方法网络请求传入数组
     parameter ： Json类型
     异步请求数据post
     */
    public func asynchronousPostRequestArrWithUrlJson(_ url: String, withDataArr dataArr: Array<Any>, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // 2. 请求(可以改的请求)
        let request:NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: urlEncoding!)! as URL)
        // ? POST
        // 默认就是GET请求
        request.httpMethod = "POST"
        
        // ? 数据体
        var jsonData:NSData? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: dataArr, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
        } catch {
            
        }
        
        // 将字符串转换成数据
        request.httpBody = (jsonData! as Data)
        
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            DispatchQueue.main.async(execute: {
                if error != nil
                {
                    // 失败回调closure
                    failedClosure("数据请求出错，请稍后重试")
                }
                else
                {
                    // 成功回调closure
                    print(JSON(data as Any))
                    successClosure(JSON(data as Any))
                }
            })
        }
        task.resume()
    }
    
    
    /**
     异步请求 get
     */
    public func asynchronousGetRequestWithUrl(_ url: String, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlEncoding!, method: .get, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                //                print(JSON(response.result.value!))
                let json = JSON(response.result.value!)
                successClosure(json)
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
    }
    
    /**
     异步请求 get 2
     */
    public func asynchronousGetRequestWithUrl(_ url: String, withDataDic dataDic: NSDictionary, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        
        Alamofire.request(urlEncoding!, method: .get, parameters: dataDic as? Parameters, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                print(JSON(response.result.value!))
                successClosure(JSON(response.result.value!))
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
        
    }
    
    /**
     异步请求数据post
     */
    public func asynchronousPostRequestWithUrl(_ url: String, withDataDic dataDic: NSDictionary, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlEncoding!, method: .post, parameters: dataDic as? Parameters, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                //                print(JSON(response.result.value!))
                successClosure(JSON(response.result.value!))
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
        
    }
    
    /**
     异步请求数据post 带token
     */
//    func asynchronousPostRequestWithUrlWithToken(_ url: String, withDataDic dataDic: NSDictionary, withToken token:String, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
//        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//
//        Alamofire.request(urlEncoding!, method: HTTPMethod.post, parameters: dataDic as? Parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json", "token": token, "userId":userManager.shared.userId,"version": nowVersion]).responseJSON { response in
//            if response.result.isSuccess {
//                // 成功回调closure
//                print(JSON(response.result.value!))
//                successClosure(JSON(response.result.value!))
//            } else {
//                // 失败回调closure
//                failedClosure("数据请求出错，请稍后重试")
//            }
//        }
//
//    }
    
    
    /**
     异步请求数据patch
     */
    public func asynchronousPatchRequestWithUrl(_ url: String, withDataDic dataDic: NSDictionary, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlEncoding!, method: .patch, parameters: dataDic as? Parameters, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                print(JSON(response.result.value!))
                successClosure(JSON(response.result.value!))
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
    }
    
    /**
     异步请求数据put
     */
    public func asynchronousPutRequestWithUrl(_ url: String, withDataDic dataDic: NSDictionary, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlEncoding!, method: .put, parameters: dataDic as? Parameters, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                print(JSON(response.result.value!))
                successClosure(JSON(response.result.value!))
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
    
    }
    
    /**
     异步请求数据 delete
     */
    public func asynchronousDeleteRequestWithUrl(_ url: String, withDataDic dataDic: NSDictionary, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlEncoding!, method: .delete, parameters: dataDic as? Parameters, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                print(JSON(response.result.value!))
                successClosure(JSON(response.result.value!))
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
    }
    
    /**
     parameter ： Json类型
     异步请求数据post
     */
    public func asynchronousPostRequestWithUrlJson(_ url: String, withDataDic dataDic: NSDictionary, withSuccess successClosure: @escaping requestSuccessClosureToOC, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        
        Alamofire.request(urlEncoding!, method: .post, parameters: dataDic as? Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                print(JSON(response.result.value!))
                successClosure(JSON(response.result.value!))
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
        
    }
    
    /**
     parameter ： Json类型
     异步请求数据put
     */
    public func asynchronousPutRequestWithUrlJson(_ url: String, withDataDic dataDic: NSDictionary, withSuccess successClosure: @escaping requestSuccessClosureToOC, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlEncoding!, method: .put, parameters: dataDic as? Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                // 成功回调closure
                print(JSON(response.result.value!))
                successClosure(JSON(response.result.value!))
            } else {
                // 失败回调closure
                failedClosure("数据请求出错，请稍后重试")
            }
        }
        
    }
    
    /**
     *上传图片
     */
    public func asynchronousPostUploadRequestWithUrl(_ url: String, withRequest: Data ,withImages imageArr: NSArray, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
  
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // 将本地的文件上传至服务器
                for i in 0..<imageArr.count {

                    let dddd = imageArr[i] as! UIImage

                    let imageData = CommonLogic.image(with: dddd)

                    //let imageData = UIImageJPEGRepresentation(imageArr[i] as! UIImage, 0.5) as! Data

                    let date = NSDate()
                    let timeInterval = date.timeIntervalSince1970 * 1000

                    multipartFormData.append(imageData!, withName: "file", fileName: "\(timeInterval).jpg", mimeType: "image/jpg")
                    multipartFormData.append(withRequest, withName: "request")

                }
        },
            //to: "\(urlEncoding!)/post",
            to: "\(urlEncoding!)",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        print(response.result.value!)
                        successClosure(JSON(response.result.value!))
                    }

                case .failure(let encodingError):
                    print(encodingError)
                    // 失败回调closure
                    failedClosure("数据请求出错，请稍后重试")
                }
        }
        )
        
    }
        
    /**
     *上传附件
     */
    public func asynchronousPostUploadRequestWithUrl(_ url: String, withRequest: Data ,withImages imageArr: NSArray, withImageNames imageNameArr: NSArray, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // 将本地的文件上传至服务器
                for i in 0..<imageArr.count {
                    
//                    let imageData = UIImageJPEGRepresentation(imageArr[i] as! UIImage, 0.7)
                    
                    let dddd = imageArr[i] as! UIImage
                    
                    let imageData = CommonLogic.image(with: dddd)
                    
                    //let imageData = imageArr[i] as! Data
                    
                    multipartFormData.append(imageData!, withName: "file", fileName: "\(imageNameArr[i]).jpg", mimeType: "image/jpg")
                    multipartFormData.append(withRequest, withName: "request")
                }
        },
            //to: "\(urlEncoding!)/post",
            to: "\(urlEncoding!)",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
//                        debugPrint(response)
//                        print(response.result.value!)
                        successClosure(JSON(response.result.value!))
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                    // 失败回调closure
                    failedClosure("数据请求出错，请稍后重试")
                }
        }
        )
        
    }
    
    /**
     *上传附件--0C
     */
    public func asynchronousPostUploadRequestWithUrlTOOC(_ url: String, withImages imageArr: NSArray, withSuccess successClosure: @escaping requestSuccessClosureToOC, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // 将本地的文件上传至服务器
                for i in 0..<imageArr.count {
                    let imageData = imageArr[i] as! Data
                    
                    multipartFormData.append(imageData, withName: "uploadFile")
                }
        },
            to: "\(urlEncoding!)/post",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        print(response.result.value!)
                        successClosure(JSON(response.result.value!))
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                    // 失败回调closure
                    failedClosure("数据请求出错，请稍后重试")
                }
        }
        )
        
    }
    
    /**
     上传附件,带进度条 demo
     */
    public func asynchronousPostUploadWithProgress() {
        
        let fileURL = Bundle.main.url(forResource: "video", withExtension: "mov")
        
        Alamofire.upload(fileURL!, to: "https://httpbin.org/post")
            .uploadProgress { progress in // main queue by default
                print("Upload Progress: \(progress.fractionCompleted)")
            }
            .responseJSON { response in
                if response.result.isSuccess {
                    // 成功回调closure
                    print(response.result.value!)
                } else {
                    // 失败回调closure
                }
                debugPrint(response)
        }
        
    }
    
    /**
     下载附件,带进度条
     */
    public func asynchronousDownloadWithProgressRequestWithUrl(_ url: String, withPathName pathName: String, withViewController controller:UIViewController, withSuccess successClosure: @escaping requestSuccessClosure, failed failedClosure: @escaping requestFailedClosure) {
        let urlEncoding = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // 加载进度条toolbar
        statusToolbar.frame = CGRect(x: 0, y: controller.view.frame.size.height - 44, width: controller.view.frame.size.width, height: 44)
        statusToolbar.actionDelegate = self
        controller.view.addSubview(statusToolbar)
        
        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            let fileURL = documentsURL.appendingPathComponent("/" + pathName)
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            print(fileURL)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        // 定时器每隔一秒更新下载文件大小
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(NetworkEngine.showFileCompleteAction(_:)), userInfo: nil, repeats: true)
        
        downloadRequest = Alamofire.download(urlEncoding!, to: destination)
            .downloadProgress { progress in
                
                let bytesString = "\(progress.completedUnitCount)" as NSString
                let byte64 = bytesString.floatValue
                
                let expectedbytesString = "\(progress.totalUnitCount)" as NSString
                
                // 总大小
                if expectedbytesString.floatValue/1024 > 1024 {
                    if self.statusLabelString.isEmpty {
                        self.statusToolbar.titleLabel!.text = "\(String(format: "%.2f", byte64/1024/1024))M / \(String(format: "%.2f", expectedbytesString.floatValue/1024/1024))M"
                    }
                    self.statusLabelString = "\(String(format: "%.2f", byte64/1024/1024))M / \(String(format: "%.2f", expectedbytesString.floatValue/1024/1024))M"
                } else {
                    if self.statusLabelString.isEmpty {
                        self.statusToolbar.titleLabel!.text = "\(String(format: "%.2f", byte64/1024))K / \(String(format: "%.2f", expectedbytesString.floatValue/1024))K"
                    }
                    self.statusLabelString = "\(String(format: "%.2f", byte64/1024))K / \(String(format: "%.2f", expectedbytesString.floatValue/1024))K"
                }
                
                self.statusToolbar.progressBar!.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            .responseData { response in
                self.timer?.invalidate() // 关闭定时器
                self.stopUILoading() // 关闭下载进度
                
                
                if response.result.isSuccess {
                    if let path = response.destinationURL?.path {
                        print("=======")
                        print(path)
                    }
                    successClosure(JSON(response.result.value!))
                    
                } else {
                    failedClosure("下载失败，请稍后再试")
                    
                    let documentsU = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileU = documentsU.appendingPathComponent("/" + pathName)
                    do {
                        try FileManager.default.removeItem(at: fileU)
                    } catch {
                        
                    }
                }
        }
        
    }
    
    /**
     * KKProgressToolbarDelegate
     * called when the user cancels the action
     */
    public func didCancelButtonPressed(_ toolbar: KKProgressToolbar) {
        downloadRequest?.cancel()
    }
    
    public func startUILoading() {
        statusToolbar.show(true) { (finished) -> Void in
            self.statusToolbar.progressBar!.setProgress(0, animated: false)
            self.statusLabelString = ""
        }
    }
    
    public func stopUILoading() {
        statusToolbar.hide(true) { (finished) -> Void in
            self.statusToolbar.progressBar!.setProgress(0, animated: false)
            self.statusLabelString = ""
            
        }
    }
    
    @objc func showFileCompleteAction(_ timer: Timer) {
        // 显示文件下载进度大小
        self.statusToolbar.titleLabel!.text = statusLabelString
        
        
    }
    
    

    
    
    func cancelDownloadFile() {
        downloadRequest?.cancel()
    }
    
}
