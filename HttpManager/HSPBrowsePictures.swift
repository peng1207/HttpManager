//
//  HSPBrowsePictures.swift
//  HttpManager
//
//  Created by Mac on 2018/1/15.
//  Copyright © 2018年 Mac. All rights reserved.
//

import Foundation
import UIKit

class HSPBrowsePicturesVC : UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    /** 图片数据源 */
    var picturesArray : Array<Any>?
    fileprivate var pictureCollectView : UICollectionView!
    /** 移动手势 */
    fileprivate var panGesture : UIPanGestureRecognizer!
    /** 宽度的约束 */
    fileprivate var widthConstraint : NSLayoutConstraint!
    /** 高度的约束 */
    fileprivate var heightConstraint : NSLayoutConstraint!
    /** 左边的约束 */
    fileprivate var leftConstraint : NSLayoutConstraint!
    /** 顶部的约束 */
    fileprivate var topConstraint : NSLayoutConstraint!
    /** 最小的宽度 */
    fileprivate let minWidth : CGFloat = 120
    /** 最小的高度 */
    fileprivate let minHeight : CGFloat = 200
    /** 保留最后一次移动的位置 */
    fileprivate var lastPoint : CGPoint! = CGPoint(x: 0, y: 0)
    /** 颜色值的透明度 */
    fileprivate var alpha : CGFloat = 1.00
    /** 手势结束时 跟最小的误差值移除 */
    fileprivate let mistakeSpace : CGFloat = 30.00
    fileprivate let k_BrowsePictureCellIdentifier = "browsePictureCellIdentifier"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
        self.addGesture()
        self.viewBackgroundColor(alpha: alpha)
    }
    /**
     添加UI
     */
    fileprivate func createUI() -> Void{
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        pictureCollectView = UICollectionView(frame: CGRect(), collectionViewLayout: flowLayout)
        pictureCollectView.backgroundColor = UIColor.white.withAlphaComponent(0)
        pictureCollectView.isPagingEnabled = true
        pictureCollectView.delegate = self
        pictureCollectView.dataSource = self
        pictureCollectView.register(HSPBrowsePictureCell.self, forCellWithReuseIdentifier: k_BrowsePictureCellIdentifier)
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
        self.view.addGestureRecognizer(panGesture)
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
            viewBackgroundColor(alpha: alpha)
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
            alpha = alpha - 0.002
        }else{
            // 往上
            width = widthConstraint.constant + widthSpace
            height  = heightConstraint.constant + heightSpace
            alpha = alpha + 0.002
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
        
        if alpha > 1.00{
            alpha = 1.00
        }else if alpha < 0.1 {
            alpha = 0.1
        }
        return (width,height)
    }
    /**
     判断手势状态
     */
    fileprivate func equalPanState(pan:UIPanGestureRecognizer) -> Bool {
        if pan.state == UIGestureRecognizerState.ended || pan.state == UIGestureRecognizerState.cancelled{
            // 手势移动结束
            if widthConstraint.constant <=  minWidth - self.view.frame.size.width + mistakeSpace && heightConstraint.constant <= minHeight - self.view.frame.size.height + mistakeSpace {
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
        alpha = 1.00
        viewBackgroundColor(alpha: alpha)
    }
    /**
     view的背景颜色
     */
    fileprivate func viewBackgroundColor(alpha:CGFloat) -> Void{
        self.view.backgroundColor = UIColor.black.withAlphaComponent(alpha)
  
    }
}
//MARK: delegate
extension HSPBrowsePicturesVC{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: k_BrowsePictureCellIdentifier, for: indexPath)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    //分区数
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
}
