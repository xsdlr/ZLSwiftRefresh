//
//  ZLSwiftHeadView.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-6.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

class ZLSwiftHeadView: UIView {
    
    var headLabel: UILabel = UILabel()
    var headImageView : UIImageView = UIImageView()
    var scrollView:UIScrollView = UIScrollView()
    var animation:RefreshAnimationStatus = .WawaAnimation {
        willSet{
            if (newValue == .WawaAnimation){
                self.headLabel.hidden = true
            }else if(newValue == .ArrowAnimation){
                self.headImageView.hidden = true
                self.headLabel.hidden = false
            }
        }
        
    }
    
    var title:String {
        set {
            headLabel.text = newValue
        }
        
        get {
            return headLabel.text!
        }
    }
    
    var imgName:String {
        set {
            if(self.animation == .WawaAnimation){
                self.headImageView.image = UIImage(named: "dropdown_anim__000\(newValue)")
            }else if(self.animation == .ArrowAnimation){
                self.headImageView.image = UIImage(named: "arrow")
                if (CGFloat(newValue.toInt()!) > self.frame.size.height * 0.8){
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.headImageView.transform = CGAffineTransformMakeRotation(CGFloat( M_PI))
                    })
                }else{
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.headImageView.transform = CGAffineTransformIdentity;
                    })
                }
            }
        }
        
        get {
            return self.imgName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI(){
        var headImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        headImageView.contentMode = .Center
        headImageView.clipsToBounds = true;
        self.addSubview(headImageView)
        self.headImageView = headImageView
        
        var headLabel:UILabel = UILabel(frame: self.frame)
        headLabel.textAlignment = .Center
        headLabel.clipsToBounds = true;
        self.addSubview(headLabel)
        self.headLabel = headLabel
    }

    func startAnimation(){
        
        if (self.animation == .ArrowAnimation){
            self.headLabel.hidden = false
            self.headImageView.hidden = true
            self.headLabel.text = "正在为您加载中.."
        }else if(self.animation == .WawaAnimation){
            var results:[AnyObject] = []
            
            for i in 1..<4{
                if let image = UIImage(named: "dropdown_loading_0\(i).png") {
                    results.append(image)
                }
            }
            
            self.headImageView.animationImages = results as [AnyObject]?
            self.headImageView.animationDuration = 0.6;
            self.headImageView.animationRepeatCount = 0;
            self.headImageView.startAnimating()
        }
        
    }
    
    func stopAnimation(){
        
        if (self.animation == .ArrowAnimation){
            self.headLabel.hidden = true
            self.headImageView.hidden = false
        }else if(self.animation == .WawaAnimation){
            self.headLabel.hidden = true
        }

        if (self.headImageView.isAnimating()){
            self.headImageView.stopAnimating()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        headImageView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5)
        headLabel.frame = self.frame
        headLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5)
    }
    
    deinit{
        if (addObserverNum == 0){
            self.scrollView.removeObserver(self.scrollView, forKeyPath: contentSizeKeyPath)
            self.scrollView.removeObserver(self.scrollView, forKeyPath: contentOffsetKeyPath)
            scrollView.clearAnimation()
        }
    }
}

