//
//  UIButton+Cache.swift
//  HttpManager
//
//  Created by Mac on 2018/1/13.
//  Copyright © 2018年 Mac. All rights reserved.
//

import Foundation
import UIKit

let HSP_button_imageKey : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "HSP_button_imageKey".hashValue)
let HSP_button_BackgroundImageKey : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "HSP_button_BackgroundImageKey".hashValue)

extension UIButton{
    /** 保存image各状态的图片 */
   fileprivate var imageStateCache : Dictionary<String, Any>?{
        set{
            objc_setAssociatedObject(self, HSP_button_imageKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            return (objc_getAssociatedObject(self, HSP_button_imageKey) as? Dictionary<String, Any>)
        }
    }
    /** 保存backgroundImage各状态的图片 */
    fileprivate var backgroundImageStateCache : Dictionary<String, Any>?{
        set{
            objc_setAssociatedObject(self, HSP_button_BackgroundImageKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            return (objc_getAssociatedObject(self, HSP_button_BackgroundImageKey) as? Dictionary<String, Any>)
        }
    }
    
    func hsp_image(url:URL,state:UIControlState,placeholderImage:UIImage? = nil) -> Void{
        hsp_image(url: url, state: state, placeholderImage: placeholderImage, complete: nil)
    }
    
    func hsp_image(url:URL,state:UIControlState,placeholderImage:UIImage?,progressBlock:HSPImageProgressBlock? = nil ,complete:HSPImageBlock?) -> Void{
        hsp_setImage(image: placeholderImage, state: state)
        
        if let image = getCacheImage(forState: state) {
            hsp_setImage(image: image, state: state)
            return
        }
        
        HSPImageDownload.shareDownload.download(url: url, progressBlock: {(progress:Float) in
            if let progressComplete = progressBlock{
                progressComplete(progress)
            }
        }, complete: { [weak self](image:UIImage?,error:Error?) in
            
            if let imageData = image{
                self?.hsp_setImage(image: imageData, state: state)
            }
            self?.setCacheImage(image: image, state: state)
            if let imageBlock = complete{
                imageBlock(image,error)
            }
        })
    }
    
    func hsp_backgroundImage(url:URL,state:UIControlState,placeholderImage:UIImage? = nil) -> Void{
        hsp_backgroundImage(url: url, state: state, placeholderImage: placeholderImage, complete: nil)
    }
    
    func hsp_backgroundImage(url:URL,state:UIControlState,placeholderImage:UIImage?,progressBlock:HSPImageProgressBlock? = nil ,complete:HSPImageBlock?) -> Void{
        hsp_setBackgroundImage(image: placeholderImage, state: state)
        if let image = getCacheBackGroundImage(forState: state){
             hsp_setBackgroundImage(image: image, state: state)
        }
        
        HSPImageDownload.shareDownload.download(url: url, progressBlock: { (progress : Float) in
            if let progressComolete = progressBlock{
                progressComolete(progress)
            }
        }, complete: { [weak self](image:UIImage?,error:Error?) in
            if let imageData = image {
                self?.hsp_setBackgroundImage(image: imageData, state: state)
            }
            self?.setCacheBackground(image: image, state: state)
            if let imageBlock = complete{
                imageBlock(image,error)
            }
        })
    }
    
    fileprivate func setCacheImage(image:UIImage?,state:UIControlState) -> Void{
          setImageStateCache()
        if let cacheImage = image {
            imageStateCache![stateImageKey(state: state)] = cacheImage
        }
    }
    
    fileprivate func getCacheImage(forState state : UIControlState) -> UIImage?{
        setImageStateCache()
        return imageStateCache![stateImageKey(state: state)] as? UIImage
    }
    
    fileprivate func stateImageKey(state : UIControlState) -> String {
        return "HSPCacheStateKey\(state)"
    }
    
    fileprivate func setCacheBackground(image:UIImage?,state:UIControlState) -> Void{
        if let imageData = image{
            setBackgroundImageStateCache()
            backgroundImageStateCache![ stateBackgroundKey(state: state) ] = imageData
        }
    }
    
    fileprivate func getCacheBackGroundImage(forState state :UIControlState) -> UIImage?{
        setBackgroundImageStateCache()
        return  backgroundImageStateCache![stateBackgroundKey(state: state)] as? UIImage
    }
    
    fileprivate func stateBackgroundKey(state:UIControlState) -> String{
        return "HSPCacheBackgroundStateKey\(state)"
    }
    
    fileprivate func hsp_setImage(image:UIImage?,state:UIControlState) -> Void{
        DispatchQueue.main.async {
            self.setImage(image, for: state)
        }
    }
    
    fileprivate func hsp_setBackgroundImage(image:UIImage?,state:UIControlState) -> Void{
        DispatchQueue.main.async {
            self.setBackgroundImage(image, for: state)
        }
    }
    fileprivate func setImageStateCache(){
        if imageStateCache == nil{
            self.imageStateCache = Dictionary()
        }
    }
    fileprivate func setBackgroundImageStateCache(){
        if backgroundImageStateCache == nil {
            backgroundImageStateCache = Dictionary()
        }
    }
    
}
