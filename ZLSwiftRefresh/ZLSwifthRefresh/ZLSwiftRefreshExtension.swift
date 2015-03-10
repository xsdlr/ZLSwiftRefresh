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

var refreshStatus:RefreshStatus = .Normal
let animations:CGFloat = 60.0
var tableViewOriginContentInset:UIEdgeInsets = UIEdgeInsetsZero
var nowLoading:Bool = false

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
        footView = ZLSwiftFootView(frame: CGRectMake(self.frame.size.width / 4, -ZLSwithRefreshFootViewHeight, self.frame.size.width / 2, ZLSwithRefreshFootViewHeight))
        
        if (self.isKindOfClass(UITableView) == true){
            let tempTableView :UITableView = self as UITableView
            tempTableView.tableFooterView = footView
            tempTableView.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, -ZLSwithRefreshFootViewHeight, 0)
        }else if(self.isKindOfClass(UICollectionView) == true){
            
            let tempCollectionView :UICollectionView = self as UICollectionView
            var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
            footView.frame.origin.y = height
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

        var scrollView = self
        var tempScrollView = self
        if(self.isKindOfClass(UITableView) == true){
            tempScrollView = self as UITableView
        }
        if (keyPath == contentSizeKeyPath){
            
            if(self.isKindOfClass(UICollectionView) == true){
                let tempCollectionView :UICollectionView = self as UICollectionView
                var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
                footView.frame.origin.y = height
            }
            
        }else{
            var scrollViewContentOffsetY:CGFloat = scrollView.contentOffset.y
            // 下拉刷新
            if (scrollViewContentOffsetY <= -ZLSwithRefreshHeadViewHeight - self.contentInset.top) {
                // 提示 -》松开刷新
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
            
            
            if (
                (tempScrollView.isKindOfClass(UITableView) &&
                    tempScrollView.valueForKeyPath("tableFooterView") != nil)
                    || scrollViewContentOffsetY > 0)
            {
                // 上啦加载更多
                var nowContentOffsetY:CGFloat = scrollView.contentOffset.y + self.frame.size.height
                var tableViewMaxHeight:CGFloat = 0
                if ((tempScrollView.isKindOfClass(UITableView) &&
                    tempScrollView.valueForKeyPath("tableFooterView") != nil)
                    ){
                        tableViewMaxHeight = CGRectGetMidY(tempScrollView.valueForKeyPath("tableFooterView")!.frame)
                }else if (tempScrollView.isKindOfClass(UICollectionView)){
                    let tempCollectionView :UICollectionView = self as UICollectionView
                    var height = tempCollectionView.collectionViewLayout.collectionViewContentSize().height
                    tableViewMaxHeight = height + ZLSwithRefreshFootViewHeight
                }
                
                if (nowContentOffsetY - tableViewMaxHeight) > ZLSwithRefreshFootViewHeight * 0.3{
                    if scrollView.dragging == false && refreshStatus == .Normal {
                        if loadMoreTempAction != nil {
                            
                            refreshStatus = .LoadMore
                            UIView.animateWithDuration(0.25, animations: { () -> Void in
                                if (self.isKindOfClass(UITableView)) {
                                    scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0, 0, 0)
                                }else if(self.isKindOfClass(UICollectionView)){
                                    scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0, ZLSwithRefreshFootViewHeight, 0)
                                }
                            })
                            footView.title = ZLSwithRefreshLoadingText
                            if(loadMoreTempAction != nil){
                                loadMoreTempAction()
                                loadMoreTempAction = {}
                            }
                            
                        }
                    } else if (refreshStatus != .LoadMore){
                        footView.title = ZLSwithRefreshMessageText
                        loadMoreTempAction = loadMoreAction
                    }
                    
                    
                }else if (refreshStatus != .LoadMore){
                    loadMoreTempAction = loadMoreAction
                    footView.title = ZLSwithRefreshFootViewText
                }
            }
        }
        
    }
    
    func doneRefresh(){
        if headerView.headImageView.isAnimating() {
            headerView.stopAnimation()
        }
        if refreshStatus == .LoadMore {
            
            var offsetValue:CGFloat = 0
            if (self.isKindOfClass(UITableView)){
                offsetValue = 0
            }else{
                offsetValue = ZLSwithRefreshFootViewHeight
            }
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, offsetValue, 0)
                footView.title = ZLSwithRefreshFootViewText
            })
        }else if refreshStatus == .Refresh {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
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
                
                self.contentInset = UIEdgeInsetsMake(top! + offset, 0, self.contentInset.bottom, 0)
            })
        }
        
        refreshStatus = .Normal
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

