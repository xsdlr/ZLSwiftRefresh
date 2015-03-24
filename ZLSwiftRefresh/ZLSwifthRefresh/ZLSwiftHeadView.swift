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
    var headImageView : UIImageView = UIImageView()
    var scrollView:UIScrollView = UIScrollView()
    var customAnimation:Bool = false
    var pullImages:[UIImage] = [UIImage]()
    
    var nowLoading:Bool = false{
        willSet {
            if (newValue == true){
                self.nowLoading = newValue
                self.scrollView.contentOffset = CGPointMake(0, -ZLSwithRefreshHeadViewHeight)//UIEdgeInsetsMake(ZLSwithRefreshHeadViewHeight, 0, self.scrollView.contentInset.bottom, 0)
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
    
    var imgName:String {
        set {
            if(!self.customAnimation){
                self.headImageView.image = UIImage(named: "dropdown_anim__000\(newValue)")
            }else{
                var image = self.pullImages[newValue.toInt()!]
                self.headImageView.image = image
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
        headLabel.text = ZLSwithRefreshHeadViewText
        headLabel.textAlignment = .Center
        headLabel.clipsToBounds = true;
        self.addSubview(headLabel)
        self.headLabel = headLabel
    }

    func startAnimation(){
        if (!self.customAnimation){
            var results:[AnyObject] = []
            for i in 1..<4{
                if let image = UIImage(named: "dropdown_loading_0\(i).png") {
                    results.append(image)
                }
            }
            self.headImageView.animationImages = results as [AnyObject]?
        }
        
        self.headLabel.text = ZLSwithRefreshLoadingText
        
        if (self.customAnimation){
            var duration:Double = Double(self.pullImages.count) * 0.1
            self.headImageView.animationDuration = duration
        }else{
            self.headImageView.animationDuration = 0.6
        }
        self.headImageView.animationRepeatCount = 0
        self.headImageView.startAnimating()
    }
    
    func stopAnimation(){
        
        self.headLabel.text = ZLSwithRefreshHeadViewText
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.scrollView.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, self.scrollView.contentInset.bottom, 0)
        })
        
        self.headImageView.stopAnimating()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        headLabel.center = CGPointMake(self.frame.size.width * 0.5, self.scrollView.frame.origin.y * 0.5)
        headImageView.frame = CGRectMake(headLabel.frame.origin.x - 50 - 10, -self.scrollView.frame.origin.y, 50, self.frame.size.height)
        headLabel.frame = CGRectMake((self.frame.size.width - 150) / 2, headImageView.frame.origin.y, 150, self.frame.size.height)
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
        
        if (scrollViewContentOffsetY + self.getNavigationHeight() != 0 && scrollViewContentOffsetY <= -height - scrollView.contentInset.top + 20) {
            // 上拉刷新
            self.headLabel.text = ZLSwithRefreshRecoderText
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
            // 上拉刷新
            if (!self.headImageView.isAnimating()){
                self.headLabel.text = ZLSwithRefreshHeadViewText
            }
            refreshTempAction = self.action
        }
        
        if (self.headImageView.isAnimating()){
            self.headLabel.text = ZLSwithRefreshLoadingText
        }
        
        if (scrollViewContentOffsetY <= 0){
            var v:CGFloat = scrollViewContentOffsetY + scrollView.contentInset.top
            if ((!self.customAnimation) && (v < -animations || v > animations)){
                v = animations
            }
            
            
            if (self.customAnimation){
                v *= CGFloat(CGFloat(self.pullImages.count) / ZLSwithRefreshHeadViewHeight)
                
                if (Int(abs(v)) > self.pullImages.count - 1){
                    v = CGFloat(self.pullImages.count - 1);
                }
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

