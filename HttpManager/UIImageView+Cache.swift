//
//  UIImageView+Cache.swift
//  HttpManager
//
//  Created by Mac on 2018/1/13.
//  Copyright © 2018年 Mac. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func hsp_image(url:URL?,placeholderImage:UIImage?) -> Void{
        hsp_image(url: url, placeholderImage: placeholderImage, imageBlock: nil)
    }

    func hsp_image(url:URL?,placeholderImage:UIImage?,imageBlock:HSPImageBlock?) -> Void{
        hsp_image(url: url, placeholderImage: placeholderImage, progressBlock: nil, imageBlock: imageBlock)
    }

    func  hsp_image(url:URL?,progressBlock:HSPImageProgressBlock? = nil,imageBlock:HSPImageBlock?) -> Void{
        hsp_image(url: url, placeholderImage: nil, progressBlock: progressBlock, imageBlock: imageBlock)
    }
    
    func hsp_image(url:URL?,placeholderImage:UIImage? = nil,progressBlock:HSPImageProgressBlock? = nil,imageBlock:HSPImageBlock? = nil) -> Void{
        self.hsp_setImage(image: placeholderImage)
        // 取缓存中的数据
        HSPImageDownload.shareDownload.download(url: url, progressBlock: { (progress:Float) in
            if let progressComplete = progressBlock{
                progressComplete(progress)
            }
        }, complete: {[weak self] (image:UIImage?,error:Error?) in
            if let imageData  = image {
                self?.hsp_setImage(image: imageData)
            }else{
                self?.hsp_setImage(image: placeholderImage)
            }
            if let imageConplete = imageBlock{
                imageConplete(image,error)
            }
        })
    }
    
    fileprivate func hsp_setImage(image:UIImage?) -> Void{
        DispatchQueue.main.async {
            self.image = image
        }
    }
    
}
