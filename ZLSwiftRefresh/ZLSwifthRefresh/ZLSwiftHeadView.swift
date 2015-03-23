//
//  ZLSwiftHeadView.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-6.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

var KVOContext = ""

public class ZLSwiftHeadView: UIView {
    private var headLabel: UILabel = UILabel()
    private var headImageView : UIImageView = UIImageView()
    var scrollView:UIScrollView = UIScrollView()
    var nowLoading:Bool = false{
        willSet {
            if (newValue == true){
                self.nowLoading = newValue
                self.scrollView.contentInset = UIEdgeInsetsMake(ZLSwithRefreshHeadViewHeight, 0, self.scrollView.contentInset.bottom, 0)
            }
        }
    }
    
    private var action: (() -> ()) = {}
    var nowAction: (() -> ()) = {}    
    private var refreshTempAction:(() -> Void) = {}
    

    convenience init(action :(() -> ()), frame: CGRect) {
        self.init(frame: frame)
        self.action = action
        self.nowAction = action
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
    
    func setupUI(){
        
        var headImageView:UIImageView = UIImageView(frame: CGRectZero)
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
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.scrollView.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, self.scrollView.contentInset.bottom, 0)
        })
        
        if (self.animation == .ArrowAnimation){
            self.headLabel.hidden = true
            self.headImageView.hidden = false
        }else if(self.animation == .WawaAnimation){
            self.headLabel.hidden = true
        }
        
        self.headImageView.stopAnimating()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        headImageView.frame = CGRectMake((self.frame.size.width - 50) * 0.5, -self.scrollView.frame.origin.y, 50, self.frame.size.height)
        headLabel.frame = self.frame
        headLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5)
    }
    
    public override func willMoveToSuperview(newSuperview: UIView!) {
        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
        if (newSuperview != nil && newSuperview.isKindOfClass(UIScrollView)) {
            self.scrollView = newSuperview as UIScrollView
            newSuperview.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
        }
    }
        
    //MARK: KVO methods
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        
        if (self.action == nil) {
            return;
        }
        
        var scrollView:UIScrollView = self.scrollView
        // change contentOffset
        var scrollViewContentOffsetY:CGFloat = scrollView.contentOffset.y
        var height = ZLSwithRefreshHeadViewHeight
        if (ZLSwithRefreshHeadViewHeight > animations){
            height = animations
        }
        if (scrollViewContentOffsetY + self.getNavigationHeight() != 0 && scrollViewContentOffsetY <= -height - scrollView.contentInset.top) {
            // 上拉刷新
            if scrollView.dragging == false && self.headImageView.isAnimating() == false{
                if refreshTempAction != nil {
                    refreshStatus = .Refresh
                    self.startAnimation()
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        if scrollView.contentInset.top == 0 {
                            scrollView.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, scrollView.contentInset.bottom, 0)
                        }else{
                            scrollView.contentInset = UIEdgeInsetsMake(ZLSwithRefreshHeadViewHeight + scrollView.contentInset.top, 0, scrollView.contentInset.bottom, 0)
                        }
                        
                    })
                    
                    if (nowLoading == true){
                        nowAction()
                        nowAction = {}
                        nowLoading = false
                    }else{
                        refreshTempAction()
                        refreshTempAction = {}
                    }
                }
            }
            
        }else{
            refreshTempAction = self.action
        }
        
        if (scrollViewContentOffsetY <= 0){
            var v:CGFloat = scrollViewContentOffsetY + scrollView.contentInset.top
            if (v < -animations || v > animations){
                v = animations
            }
            
            if ((Int)(abs(v)) > 0){
                self.imgName = "\((Int)(abs(v)))"
            }
        }
    }
    
    //MARK: getNavigaition Height -> delete
    func getNavigationHeight() -> CGFloat{
        var vc = UIViewController()
        if self.getViewControllerWithView(self).isKindOfClass(UIViewController) == true {
            vc = self.getViewControllerWithView(self) as UIViewController
        }
        
        var top = vc.navigationController?.navigationBar.frame.height
        if top == nil{
            top = 0
        }
        // iOS7
        var offset:CGFloat = 20
        if((UIDevice.currentDevice().systemVersion as NSString).floatValue < 7.0){
            offset = 0
        }
        
        return offset + top!
    }
    
    func getViewControllerWithView(vcView:UIView) -> AnyObject{
        if( (vcView.nextResponder()?.isKindOfClass(UIViewController) ) == true){
            return vcView.nextResponder() as UIViewController
        }
        
        if(vcView.superview == nil){
            return vcView
        }
        
        return self.getViewControllerWithView(vcView.superview!)
    }

    
    deinit{
        var scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }
}

