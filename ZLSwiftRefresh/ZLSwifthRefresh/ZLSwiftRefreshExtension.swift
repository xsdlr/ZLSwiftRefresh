//
//  ZLSwiftRefreshExtension.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-6.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

enum RefreshStatus{
    case Normal, Refresh, LoadMore
}

// 动画模式
// WawaAnimation : 娃娃动画
// ArrowAnimation : 箭头
// 未完成 ---- 
// Text   : 纯文字
// TextAndTime : 纯文字+刷新时间
// AnimationText : 娃娃动画+文字
// AnimationTextAndTime : 娃娃动画+文字时间
enum RefreshAnimationStatus{
    case WawaAnimation, ArrowAnimation
}

let contentOffsetKeyPath = "contentOffset"
let contentSizeKeyPath = "contentSize"
var addObserverNum:NSInteger = 0;

/** refresh && loadMore callBack */
var refreshAction: (() -> Void) = {}
var loadMoreAction: (() -> Void) = {}
var nowRefreshAction: (() -> Void) = {}

var refreshTempAction:(() -> Void) = {}
var loadMoreTempAction:(() -> Void) = {}
var loadMoreEndTempAction:(() -> Void) = {}

var refreshStatus:RefreshStatus = .Normal
var refreshAnimationStatus:RefreshAnimationStatus = .WawaAnimation
let animations:CGFloat = 60.0
var tableViewOriginContentInset:UIEdgeInsets = UIEdgeInsetsZero
var nowLoading:Bool = false
var isEndLoadMore:Bool = false
var valueOffset:CGFloat = 0
var headerView:ZLSwiftHeadView = ZLSwiftHeadView(frame: CGRectZero)
var footView:ZLSwiftFootView = ZLSwiftFootView(frame: CGRectZero)

extension UIScrollView: UIScrollViewDelegate {
    
    //MARK: Refresh
    //下拉刷新
    func toRefreshAction(action :(() -> Void)){
        if addObserverNum > 0 {
            addObserverNum = 0;
        }
        
        self.addOnlyAction();
        self.addHeadView()
        refreshAction = action
    }
    
    func toRefreshAction(_ status: RefreshAnimationStatus = .WawaAnimation , action :(() -> Void)){
        refreshAnimationStatus = status
        self.toRefreshAction(action)
    }
    
    //MARK: LoadMore
    //上拉加载更多
    func toLoadMoreAction(action :(() -> Void)){
        self.addOnlyAction();
        self.addFootView()
        loadMoreAction = action
        loadMoreEndTempAction = action
    }
    
    //MARK: nowRefresh
    //立马上拉刷新
    func nowRefresh(action :(() -> Void)){
        self.addOnlyAction();
        self.addHeadView()
        nowLoading = true
        nowRefreshAction = action
        self.contentOffset = CGPointMake(0, -ZLSwithRefreshHeadViewHeight - self.contentInset.top)
    }
    
    func nowRefresh(_ status: RefreshAnimationStatus = .WawaAnimation , action :(() -> Void)){
        refreshAnimationStatus = status
        self.nowRefresh(action)
    }
    
    //MARK: endLoadMoreData
    //数据加载完毕
    func endLoadMoreData() {
        isEndLoadMore = true
        loadMoreAction = {}
        loadMoreTempAction = {}
        footView.title = ZLSwithRefreshMessageText
    }
    
    //配置信息
    func addOnlyAction(){
        self.addObserver()
        self.alwaysBounceVertical = true
        tableViewOriginContentInset = self.contentInset
    }
    
    //MARK: AddHeadView && FootView
    func addHeadView(){
        var headView:ZLSwiftHeadView = ZLSwiftHeadView(frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
        headView.scrollView = self
        headView.animation = refreshAnimationStatus
        self.addSubview(headView)
        headerView = headView
        
    }
    
    func addFootView(){
        isEndLoadMore = false
        footView = ZLSwiftFootView(frame: CGRectMake( 0 , self.frame.height, self.frame.size.width, ZLSwithRefreshFootViewHeight))
        
        if(self.isKindOfClass(UICollectionView) == true){
            let tempCollectionView :UICollectionView = self as UICollectionView
            var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
            footView.frame.origin.y = height + ZLSwithRefreshFootViewHeight / 2
            tempCollectionView.addSubview(footView)
            tempCollectionView.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, ZLSwithRefreshFootViewHeight, 0)
        }else{
            let scrollView :UIScrollView = self as UIScrollView
            scrollView.addSubview(footView)
            scrollView.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0,ZLSwithRefreshFootViewHeight, 0)
        }
    }
    
    //MARK: Refresh Style in Animation.
    func setHeaderViewAnimationStatus(status:RefreshAnimationStatus){
        refreshAnimationStatus = status
        headerView.animation = status
    }
    
    func clearAnimation(){
        refreshAnimationStatus = .WawaAnimation
        headerView.animation = refreshAnimationStatus
    }
    
    //MARK: Observer KVO Method
    func addObserver(){
        if(addObserverNum == 0){
            self.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: nil)
            self.addObserver(self, forKeyPath: contentSizeKeyPath, options: .Initial, context: nil)
        }
        addObserverNum+=1
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        self.changeSelfView(keyPath)
    }
    
    //MARK: doneRefersh
    //完成刷新
    func doneRefresh(){
        headerView.stopAnimation()
        self.userInteractionEnabled = true
        if refreshStatus == .LoadMore {
            var offsetValue:CGFloat = ZLSwithRefreshFootViewHeight

            if (self.dragging == false){
                footView.title = ZLSwithRefreshFootViewText
            }
            
            if (self.isKindOfClass(UICollectionView)) {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, offsetValue + ZLSwithRefreshFootViewHeight + ZLSwithRefreshFootViewHeight / 2, 0)
                })
                
                // footView必须超过了屏幕才进行计算
                if (
                    footView.frame.origin.y - footView.frame.height * 2 > self.frame.height && self.contentOffset.y + self.frame.height < footView.frame.origin.y + footView.frame.height ){
                    self.contentOffset.y = self.contentOffset.y - ZLSwithRefreshFootViewHeight
                }
            }else{
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, offsetValue, 0)
                })
            }
        }else if refreshStatus == .Refresh {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, self.contentInset.bottom, 0)
            })
            
            // Reset LoadMore status
            loadMoreAction = loadMoreEndTempAction
            loadMoreTempAction = loadMoreAction
            isEndLoadMore = false
        }
        
        refreshStatus = .Normal
    }
    
    func changeSelfView(keyPath:String){
        
        if (refreshAction == nil && loadMoreAction == nil && nowRefreshAction == nil) {
            return;
        }
        
        var scrollView = self
        if (keyPath == contentSizeKeyPath){
            // change contentSize
            if(self.isKindOfClass(UICollectionView) == true){
                let tempCollectionView :UICollectionView = self as UICollectionView
                var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
                footView.frame.origin.y = height
            }else{
                footView.frame.origin.y = self.contentSize.height
            }
            
            return;
        }
        
        // change contentOffset
        var scrollViewContentOffsetY:CGFloat = scrollView.contentOffset.y
        var height = ZLSwithRefreshHeadViewHeight
        if (ZLSwithRefreshHeadViewHeight > animations){
            height = animations
        }
        if (scrollViewContentOffsetY + self.getNavigationHeight() != 0 && scrollViewContentOffsetY <= -height - self.contentInset.top) {
            // 上拉刷新
            if scrollView.dragging == false && headerView.headImageView.isAnimating() == false{
                if refreshTempAction != nil {
                    refreshStatus = .Refresh
                    headerView.startAnimation()
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        if self.contentInset.top == 0 {
                            scrollView.contentInset = UIEdgeInsetsMake(self.getNavigationHeight(), 0, scrollView.contentInset.bottom, 0)
                        }else{
                            scrollView.contentInset = UIEdgeInsetsMake(ZLSwithRefreshHeadViewHeight + self.contentInset.top, 0, scrollView.contentInset.bottom, 0)
                        }

                    })
                    
                    if (nowLoading == true){
                        nowRefreshAction()
                        nowRefreshAction = {}
                        nowLoading = false
                    }else{
                        refreshTempAction()
                        refreshTempAction = {}
                    }
                }
            }
            
        }else{
            refreshTempAction = refreshAction
        }
        
        if (scrollViewContentOffsetY <= 0){
            var v:CGFloat = scrollViewContentOffsetY + self.contentInset.top
            if (refreshAnimationStatus == .WawaAnimation){
                if (v < -animations){
                    v = animations
                }
                
                if ((Int)(abs(v)) > 0){
                    headerView.imgName = "\((Int)(abs(v)))"
                }
            }else{
                headerView.imgName = "\((Int)(abs(v)))"
            }
        }
    
        // 上拉加载更多
        if (
                scrollViewContentOffsetY > 0
            )
        {
            var nowContentOffsetY:CGFloat = scrollViewContentOffsetY + self.frame.size.height
            var tableViewMaxHeight:CGFloat = 0
            
            if (scrollView.isKindOfClass(UICollectionView))
            {
                let tempCollectionView :UICollectionView = self as UICollectionView
                var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
                tableViewMaxHeight = height
            }else if(self.contentSize.height > 0){
                tableViewMaxHeight = self.contentSize.height
            }
            
            if (self.userInteractionEnabled == true && refreshStatus == .Normal){
                loadMoreTempAction = loadMoreAction
            }
            
            if (nowContentOffsetY - tableViewMaxHeight) > valueOffset && self.contentOffset.y != 0{
                if refreshStatus == .Normal {
                    if isEndLoadMore == false && loadMoreTempAction != nil{
                        refreshStatus = .LoadMore
                        footView.title = ZLSwithRefreshLoadingText
                        loadMoreTempAction()
                        loadMoreTempAction = {}
                    }else {
                        footView.title = ZLSwithRefreshMessageText
                    }
                }
            }else if (refreshStatus != .LoadMore && isEndLoadMore == false){
                loadMoreTempAction = loadMoreAction
                footView.title = ZLSwithRefreshFootViewText
            }
        }else if (refreshStatus != .LoadMore && isEndLoadMore == false){
            footView.title = ZLSwithRefreshFootViewText
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
    
}

