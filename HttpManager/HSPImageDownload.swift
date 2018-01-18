//
//  HSPImageDownload.swift
//  HttpManager
//
//  Created by Mac on 2018/1/13.
//  Copyright © 2018年 Mac. All rights reserved.
//

import UIKit
import Foundation

typealias HSPImageBlock = (_ image:UIImage?,_ error:Error?) -> Void
typealias HSPImageProgressBlock = (_ progress : Float) -> Void

class HSPImageDownload: NSObject {
    
    static let shareDownload : HSPImageDownload = HSPImageDownload()
    /** 保存内存的数据 */
    fileprivate var imageCache : NSCache = NSCache<AnyObject, AnyObject>()
    fileprivate var failureUrl : Array<String> = Array()
    fileprivate let fileManager : FileManager = FileManager()
    /** 缓存目录 */
    fileprivate var cacheDisk : String = ""
    var totalCostLimit : Int = 0{
        didSet{
            self.imageCache.totalCostLimit = totalCostLimit
        }
    }
    var countLimit : Int = 0 {
        didSet{
            self.imageCache.countLimit = countLimit
        }
    }
    override init() {
        super.init()
        cacheDisk = diskCachePath(fullNamespace: "com.image.cacheimage")
    }
    /**
     根据链接获取对应的key
     */
    fileprivate func cacheKey(url:URL?) -> String{
        if let urlPath = url{
            return urlPath.absoluteString
        }
        return ""
    }
    /**
     内存中图片
     */
    fileprivate func cacheImage(key:String) -> UIImage?{
        return (imageCache.object(forKey: key as AnyObject) as? UIImage)
    }
    /**
     清除内存
     */
    func clearMemory() -> Void{
        imageCache.removeAllObjects()
    }
    /**
      清除缓存
     */
    func clearCache() -> Void{
       try? fileManager.removeItem(atPath: cacheDisk)
    }
    /**
      删除某个链接
     */
    func remove(url:URL?) -> Void{
        if let remoeUrl = url{
            let key = cacheKey(url: remoeUrl)
            try? fileManager.removeItem(atPath: cachePath(forKey: key, path: cacheDisk))
        }
    }
    /**
     缓存文件的目录
     */
    fileprivate func diskCachePath(fullNamespace:String) -> String{
        let cachePath : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! as NSString
        return cachePath.appendingPathComponent(fullNamespace)
    }
    /**
     进行转码
     */
    fileprivate func base64(string:String) -> String{
        let data = string.data(using: String.Encoding.utf8)
        return (data?.base64EncodedString())!
    }
    /**
     是否失效的url
     */
    fileprivate func isFailureUrl(key:String) -> Bool{
        return failureUrl.contains(key)
    }
    /**
      添加失效的链接
     */
    fileprivate func add(failureUrl key:String?) -> Void{
        if let keyUrl = key {
            failureUrl.append(keyUrl)
        }
    }
    /**
     下载
     */
    func download(url:URL?,progressBlock:HSPImageProgressBlock?,complete:HSPImageBlock?) -> Void{
        let key = cacheKey(url: url)
        // 判断内存是否存在
        if let image = cacheImage(key: key){
            downComplete(image: image, error: nil, complete: complete)
            return
        }
        // 判断缓存中是否存在
        if let image = getImage(key: key){
            downComplete(image: image, error: nil, complete: complete)
            return
        }
        
        // 判断是否为失效的url
        if isFailureUrl(key: key){
            downComplete(image: nil, error: nil, complete: complete)
            return
        }
        // 进行下载
        _ = HSPDownloadManager.download(url: url, progress: { (progress:Float) in
            if let progressComplete = progressBlock{
                progressComplete(progress)
            }
        }, success: { [weak self](data:Data?) in
            DispatchQueue.global().sync {
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    self?.downComplete(image: image, error: nil, complete: complete)
                    self?.saveCache(key: key, image: image)
                    self?.saveImage(key: key, data: imageData)
                }else{
                    self?.downComplete(image: nil, error: nil, complete: complete)
                    self?.add(failureUrl: key)
                }
            }
            }, failure: { [weak self](error:Error?) in
                self?.downComplete(image: nil, error: error, complete: complete)
                self?.add(failureUrl: key)
        })
    }
    /**
     下载之后回调
     */
    fileprivate func downComplete(image:UIImage?,error:Error?,complete:HSPImageBlock?) -> Void{
        if let completeBlock : HSPImageBlock = complete {
            DispatchQueue.main.async {
                completeBlock(image,error)
            }
        }
    }
    /**
        保存图片到缓存中
     */
    fileprivate func saveImage(key:String,data:Data?) -> Void{
        if let imageData = data{
            if !fileManager.fileExists(atPath: cacheDisk) {
               try? fileManager.createDirectory(atPath: cacheDisk, withIntermediateDirectories: true, attributes: nil)
            }
            let cachePathKey = cachePath(forKey: key, path: cacheDisk)
            fileManager.createFile(atPath: cachePathKey, contents: imageData, attributes: nil)
        }
    }
    /**
     从缓存中获取图片
     */
    fileprivate func getImage(key:String) -> UIImage?{
        let image = UIImage(contentsOfFile: cachePath(forKey: key, path: cacheDisk))
        saveCache(key: key, image: image)
        return image
    }
    /**
     缓存图片的路径
     */
    fileprivate func cachePath(forKey key:String,path:String) -> String{
        let fileName = base64(string: key)
        return (path as NSString).appendingPathComponent(fileName)
    }
    /**
     保存图片到内存中
     */
    fileprivate func saveCache(key:String?,image:UIImage?) -> Void{
        if let keyString = key,let imageData = image {
            imageCache.setObject(imageData, forKey: keyString as AnyObject)
        }
    }
    
}
