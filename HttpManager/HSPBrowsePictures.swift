//
//  HSPBrowsePictures.swift
//  HttpManager
//
//  Created by Mac on 2018/1/15.
//  Copyright © 2018年 Mac. All rights reserved.
//

import Foundation
import UIKit

class HSPBrowsePicturesVC : UIViewController {
    /** 图片数据源 */
    var picturesArray : Array<Any>?
    fileprivate var pictureCollectView : UICollectionView!
    fileprivate var panGesture : UIPanGestureRecognizer!
    fileprivate var widthConstraint : NSLayoutConstraint!
    fileprivate var heightConstraint : NSLayoutConstraint!
    fileprivate var leftConstraint : NSLayoutConstraint!
    fileprivate var topConstraint : NSLayoutConstraint!
    fileprivate let minWidth : CGFloat = 120
    fileprivate let minHeight : CGFloat = 200
    fileprivate var lastPoint : CGPoint! = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
        self.addGesture()
        self.viewBackgroundColor(alpha: 0.6)
    }
    /**
     
     */
    fileprivate func createUI() -> Void{
        pictureCollectView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        pictureCollectView.backgroundColor = UIColor.red
        self.view.addSubview(pictureCollectView)
        pictureCollectView.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint = NSLayoutConstraint(item: pictureCollectView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        self.view.addConstraint(leftConstraint)
        topConstraint = NSLayoutConstraint(item: pictureCollectView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        self.view.addConstraint(topConstraint)
        widthConstraint = NSLayoutConstraint(item: pictureCollectView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0)
        self.view.addConstraint(widthConstraint)
        heightConstraint = NSLayoutConstraint(item: pictureCollectView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0)
        self.view.addConstraint(heightConstraint)
    }
    /**
     添加手势
     */
    fileprivate func addGesture(){
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(pan:)))
        pictureCollectView.addGestureRecognizer(panGesture)
    }
    
}
//MARK: action
extension HSPBrowsePicturesVC{
    @objc fileprivate func panGestureAction(pan:UIPanGestureRecognizer) -> Void{
        if  equalPanState(pan: pan) == false {
            let point = pan.location(in: self.view)
            let viewWAndH = viewWidthAndHeight(isDow: isDown(point: point))
            widthConstraint.constant = viewWAndH.width
            heightConstraint.constant = viewWAndH.height
            leftConstraint.constant = point.x - pictureCollectView.frame.size.width/2.0
            topConstraint.constant = point.y - pictureCollectView.frame.size.height/2.0
            lastPoint = point
        }
    }
    /**
     是否往下移动
     */
    fileprivate func isDown(point:CGPoint) -> Bool{
        if point.y > lastPoint.y{
            return true
        }
        return false
    }
    
    fileprivate func viewWidthAndHeight (isDow:Bool) -> (width:CGFloat,height:CGFloat) {
        var width : CGFloat
        var height : CGFloat
        let widthSpace : CGFloat = 2.00
        let heightSpace : CGFloat = 3.50
        if isDow {
            // 往下
            width = widthConstraint.constant - widthSpace
            height  = heightConstraint.constant - heightSpace
        }else{
            // 往上
            width = widthConstraint.constant + widthSpace
            height  = heightConstraint.constant + heightSpace
        }
        
        if width > 0.00 {
            width = 0.00
        }else if width < minWidth - self.view.frame.size.width{
            width = minWidth - self.view.frame.size.width
        }
        
        if height > 0.00 {
            height = 0.00
        }else if height < minHeight - self.view.frame.size.height{
            height = minHeight - self.view.frame.size.height
        }
        return (width,height)
    }
    /**
     判断手势状态
     */
    fileprivate func equalPanState(pan:UIPanGestureRecognizer) -> Bool {
        if pan.state == UIGestureRecognizerState.ended || pan.state == UIGestureRecognizerState.cancelled{
            // 手势移动结束
            if widthConstraint.constant <=  minWidth - self.view.frame.size.width + 20.00 && heightConstraint.constant <= minHeight - self.view.frame.size.height + 20.00 {
                removeView()
            }else{
                recoveryView()
            }
            return true
        }else{
            return false
        }
    }
    /**
     移除view
     */
    fileprivate func removeView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.pictureCollectView.removeFromSuperview()
        },completion:{ (finish :Bool) in
            self.controllerPop()
        })
    }
    /**
     控制器移除
     */
    fileprivate func controllerPop(){
        self.dismiss(animated: false, completion: nil)
    }
    /**
     view 复原最原始
     */
    fileprivate func recoveryView() {
        widthConstraint.constant = 0.00
        heightConstraint.constant = 0.00
        leftConstraint.constant = 0.00
        topConstraint.constant = 0.00
        lastPoint = CGPoint(x: 0, y: 0)
    }
    /**
     view的背景颜色
     */
    fileprivate func viewBackgroundColor(alpha:CGFloat) -> Void{
            self.view.backgroundColor = UIColor.black.withAlphaComponent(alpha)
    }
}
