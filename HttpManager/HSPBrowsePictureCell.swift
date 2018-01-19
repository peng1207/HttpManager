//
//  HSPBrowsePictureCell.swift
//  HttpManager
//
//  Created by Mac on 2018/1/18.
//  Copyright © 2018年 Mac. All rights reserved.
//

import Foundation
import UIKit


class HSPBrowsePictureCell : UICollectionViewCell{
    fileprivate var pictureImageView : UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HSPBrowsePictureCell {
    /**
     创建UI
     */
    fileprivate func setupUI(){
        pictureImageView = UIImageView()
        pictureImageView.backgroundColor = UIColor.red
        self.contentView.addSubview(pictureImageView)
        pictureImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint(item: pictureImageView, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: pictureImageView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: pictureImageView, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: pictureImageView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
    
}

