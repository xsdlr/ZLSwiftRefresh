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

let contentOffsetKeyPath = "contentOffset"
let contentSizeKeyPath = "contentSize"
var addObserverNum:NSInteger = 0;
var headerView:ZLSwiftHeadView = ZLSwiftHeadView(frame: CGRectZero)
var footView:ZLSwiftFootView = ZLSwiftFootView(frame: CGRectZero)

/** refresh && loadMore callBack */
var refreshAction: (() -> ()) = {}
var loadMoreAction: (() -> ()) = {}
var nowRefreshAction: (() -> ()) = {}

var refreshTempAction:(() -> ()) = {}
var loadMoreTempAction:(() -> ()) = {}
var loadMoreEndTempAction:(() -> ()) = {}

var refreshStatus:RefreshStatus = .Normal
let animations:CGFloat = 60.0
var tableViewOriginContentInset:UIEdgeInsets = UIEdgeInsetsZero
var nowLoading:Bool = false
var isEndLoadMore:Bool = false
var valueOffset:CGFloat = 0

extension UIScrollView: UIScrollViewDelegate {
    
    //MARK: Refresh
    //下拉刷新
    func toRefreshAction(action :(() -> ())){
        if addObserverNum > 0 {
            addObserverNum = 0;
        }
        self.addOnlyAction();
        self.addHeadView()
        refreshAction = action
    }
    
    //MARK: LoadMore
    //上拉加载更多
    func toLoadMoreAction(action :(() -> ())){
        self.addOnlyAction();
        self.addFootView()
        loadMoreAction = action
        loadMoreEndTempAction = action
    }
    
    //MARK: nowRefresh
    //立马上拉刷新
    func nowRefresh(action :(() -> ())){
        self.addOnlyAction();
        self.addHeadView()
        nowLoading = true
        nowRefreshAction = action
        self.contentOffset = CGPointMake(0, -ZLSwithRefreshHeadViewHeight - self.contentInset.top)
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
        tableViewOriginContentInset = self.contentInset
    }
    
    //MARK: AddHeadView && FootView
    func addHeadView(){
        var headView:ZLSwiftHeadView = ZLSwiftHeadView(frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
        headView.scrollView = self
        self.addSubview(headView)
        headerView = headView
        
    }
    
    func addFootView(){
        isEndLoadMore = false
        footView = ZLSwiftFootView(frame: CGRectMake( 0 , -ZLSwithRefreshFootViewHeight, self.frame.size.width, ZLSwithRefreshFootViewHeight))
        
        if (self.isKindOfClass(UITableView) == true){
            let tempTableView :UITableView = self as UITableView
            tempTableView.tableFooterView = footView
            tempTableView.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, -ZLSwithRefreshFootViewHeight, 0)
        }else if(self.isKindOfClass(UICollectionView) == true){
            
            let tempCollectionView :UICollectionView = self as UICollectionView
            var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
            footView.frame.origin.y = height + ZLSwithRefreshFootViewHeight / 2
            tempCollectionView.addSubview(footView)
            tempCollectionView.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, ZLSwithRefreshFootViewHeight, 0)
        }
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
        if headerView.headImageView.isAnimating() {
            headerView.stopAnimation()
        }
        
        self.userInteractionEnabled = true
        if refreshStatus == .LoadMore {
            

            var offsetValue:CGFloat = 0
            if (self.isKindOfClass(UITableView)){
                offsetValue = 0
            }else{
                offsetValue = ZLSwithRefreshFootViewHeight
            }
            
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
        var scrollView = self
        
        if (keyPath == contentSizeKeyPath){
            // change contentSize
            if(self.isKindOfClass(UICollectionView) == true){
                let tempCollectionView :UICollectionView = self as UICollectionView
                var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
                footView.frame.origin.y = height + ZLSwithRefreshFootViewHeight / 2
            }
            
            return;
        }
        
        // change contentOffset
        var scrollViewContentOffsetY:CGFloat = scrollView.contentOffset.y
        var height = ZLSwithRefreshHeadViewHeight
        if (ZLSwithRefreshHeadViewHeight > animations){
            height = animations
        }
        if (scrollViewContentOffsetY <= -height - self.contentInset.top) {
            // 上拉刷新
            if scrollView.dragging == false && headerView.headImageView.isAnimating() == false{
                if refreshTempAction != nil {
                    refreshStatus = .Refresh
                    headerView.startAnimation()
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        scrollView.contentInset = UIEdgeInsetsMake(ZLSwithRefreshHeadViewHeight + self.contentInset.top, 0, scrollView.contentInset.bottom, 0)
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
            var v:CGFloat = scrollViewContentOffsetY + self.contentInset.top
            if (v < -animations){
                v = animations
            }
            
            if ((Int)(abs(v)) > 0){
                headerView.imgName = "\((Int)(abs(v)))"
            }
        }
        
        // 上拉加载更多
        if (
            (scrollView.isKindOfClass(UITableView) &&
                scrollView.valueForKeyPath("tableFooterView") != nil) ||
                scrollViewContentOffsetY > 0
            )
        {
            var nowContentOffsetY:CGFloat = scrollViewContentOffsetY + self.frame.size.height
            var tableViewMaxHeight:CGFloat = 0
            
            if (
                scrollView.isKindOfClass(UITableView) &&
                    scrollView.valueForKeyPath("tableFooterView") != nil
                )
            {
                tableViewMaxHeight = CGRectGetMidY(scrollView.valueForKeyPath("tableFooterView")!.frame)
            }else if (scrollView.isKindOfClass(UICollectionView))
            {
                let tempCollectionView :UICollectionView = self as UICollectionView
                var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
                tableViewMaxHeight = height
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

