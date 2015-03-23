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

var refreshStatus:RefreshStatus = .Normal
var refreshAnimationStatus:RefreshAnimationStatus = .WawaAnimation
let animations:CGFloat = 60.0
var tableViewOriginContentInset:UIEdgeInsets = UIEdgeInsetsZero

extension UIScrollView: UIScrollViewDelegate {
    
    //MARK: Refresh
    //下拉刷新
    func toRefreshAction(action :(() -> Void)){
        self.toRefreshAction(.WawaAnimation, action: action)
    }
    
    func toRefreshAction(_ status: RefreshAnimationStatus = .WawaAnimation , action :(() -> Void)){
        refreshAnimationStatus = status
        
        if var headView = self.viewWithTag(ZLSwiftHeadViewTag) {
            
        }else{
            var headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
            headView.scrollView = self
            headView.tag = ZLSwiftHeadViewTag
            headView.animation = refreshAnimationStatus
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
        var headView:ZLSwiftHeadView = ZLSwiftHeadView(action: action,frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
        headView.scrollView = self
        headView.tag = ZLSwiftHeadViewTag
        headView.animation = refreshAnimationStatus
        headView.nowLoading = true
        headView.nowAction = action
        
        self.addSubview(headView)
        
    }
    
    func nowRefresh(_ status: RefreshAnimationStatus = .WawaAnimation , action :(() -> Void)){
        self.alwaysBounceVertical = true
        self.nowRefresh(action)
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

