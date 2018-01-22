//
//  HSPDownloadManager.swift
//  HttpManager
//
//  Created by Mac on 2018/1/12.
//  Copyright © 2018年 Mac. All rights reserved.
//

import UIKit

typealias HSPDownloadSuccess = (_ data:Data?) -> Void
typealias HSPDownloadFailure = (_ error:Error?) -> Void
typealias HSPDownloadProgress = (_ progress:Float) -> Void


class HSPDownloadManager: NSObject,URLSessionDownloadDelegate{
   
    fileprivate var session : URLSession!
    fileprivate var downloadSessionTask : URLSessionDownloadTask?
    fileprivate var success : HSPDownloadSuccess?
    fileprivate var failure : HSPDownloadFailure?
    fileprivate var progressBlock : HSPDownloadProgress?
    /**
     下载文件
     */
   public class func download(url:URL?,success:HSPDownloadSuccess?,failure:HSPDownloadFailure?) -> HSPDownloadManager? {
       return download(url: url, progress: nil, success: success, failure: failure)
    }
    
    public class func download(url:URL?,progress:HSPDownloadProgress?,success:HSPDownloadSuccess?,failure:HSPDownloadFailure?) -> HSPDownloadManager?{
        guard let requestUrl = url else {
            if let failureBlock = failure{
                failureBlock(nil)
            }
            return nil
        }
        let downloadManager = HSPDownloadManager()
        downloadManager.initData(url: requestUrl, progress: progress, success: success, failure: failure)
        return downloadManager
    }
    
    override  init(){
        super.init()
        session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue:  OperationQueue.main)
    }
    
  fileprivate func initData(url:URL,progress:HSPDownloadProgress?,success:HSPDownloadSuccess?,failure:HSPDownloadFailure?) -> Void {
        self.progressBlock = progress
        self.success = success
        self.failure = failure
        let request = URLRequest(url: url)
        downloadSessionTask = session.downloadTask(with: request)
        downloadSessionTask?.resume()
    }
    
    //MARK: delete
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("location url is \(location.path)")
        let data = try? Data(contentsOf: location)
        if data != nil {
            if let successBlock = success{
                successBlock(data)
            }
        }else{
            if let failureBlock = failure{
                failureBlock(nil)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let progressBlock = progressBlock{
            let progress = (Float(integerLiteral: totalBytesWritten))/(Float(integerLiteral: totalBytesExpectedToWrite))
            progressBlock(progress)
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("error is \(String(describing: error))")
    }
    
}
