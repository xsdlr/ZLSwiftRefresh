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

enum HeaderViewRefreshAnimationStatus{
    case headerViewRefreshPullAnimation, headerViewRefreshLoadingAnimation
}

var refreshStatus:RefreshStatus = .Normal
let animations:CGFloat = 60.0
var tableViewOriginContentInset:UIEdgeInsets = UIEdgeInsetsZero

extension UIScrollView: UIScrollViewDelegate {
    
    public var headerRefreshView: ZLSwiftHeadView? {
        get {
            var headerRefreshView = viewWithTag(ZLSwiftHeadViewTag)
            return headerRefreshView as? ZLSwiftHeadView
        }
    }
    
    //MARK: Refresh
    //下拉刷新
    func toRefreshAction(action :(() -> Void)){
        
        self.alwaysBounceVertical = true
        if self.headerRefreshView == nil{
            var headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }
    }
    
    //MARK: LoadMore
    //上拉加载更多
    func toLoadMoreAction(action :(() -> Void)){
        var footView = ZLSwiftFootView(action: action, frame: CGRectMake( 0 , UIScreen.mainScreen().bounds.size.height - ZLSwithRefreshFootViewHeight, self.frame.size.width, ZLSwithRefreshFootViewHeight))
        footView.tag = ZLSwiftFootViewTag
        self.addSubview(footView)
    }
    
    //MARK: nowRefresh
    //立马上拉刷新
    func nowRefresh(action :(() -> Void)){
        
        self.alwaysBounceVertical = true
        if self.headerRefreshView == nil {
            var headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            self.addSubview(headView)
        }
        
        self.headerRefreshView?.nowLoading = true
        self.headerRefreshView?.nowAction = action
    }

    func headerViewRefreshAnimationStatus(status:HeaderViewRefreshAnimationStatus, images:[UIImage]){
        
        self.headerRefreshView?.customAnimation = true
        
        if (status == .headerViewRefreshLoadingAnimation){
            self.headerRefreshView?.headImageView.animationImages = images
        }else{
            self.headerRefreshView?.headImageView.image = images.first
            self.headerRefreshView?.pullImages = images
        }
        
    }
    
    //MARK: endLoadMoreData
    //数据加载完毕
    func endLoadMoreData() {
        var footView:ZLSwiftFootView = self.viewWithTag(ZLSwiftFootViewTag) as ZLSwiftFootView
        footView.isEndLoadMore = true
    }
    
    //MARK: doneRefersh
    //完成刷新
    func doneRefresh(){
        if var headerView:ZLSwiftHeadView = self.viewWithTag(ZLSwiftHeadViewTag) as? ZLSwiftHeadView {
            headerView.stopAnimation()
        }
        refreshStatus = .Normal
    }
    
}

