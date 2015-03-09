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
    func toRefreshAction(action :(() -> ())){
        if addObserverNum > 0 {
            addObserverNum = 0;
        }
        self.addOnlyAction();
        self.addHeadView()
        refreshAction = action
    }
    
    //MARK: LoadMore
    func toLoadMoreAction(action :(() -> ())){
        self.addOnlyAction();
        self.addFootView()
        loadMoreAction = action
    }
    
    func nowRefresh(action :(() -> ())){
        self.addOnlyAction();
        self.addHeadView()
        nowLoading = true
        nowRefreshAction = action
        self.contentOffset = CGPointMake(0, -ZLSwithRefreshHeadViewHeight - self.contentInset.top)
    }
    
    func addOnlyAction(){
        self.addObserver()
        let tempTableView: UITableView = self as UITableView;
        tableViewOriginContentInset = tempTableView.contentInset
    }
    
    //MARK: AddHeadView && FootView
    func addHeadView(){
        var headView:ZLSwiftHeadView = ZLSwiftHeadView(frame: CGRectMake(0, -ZLSwithRefreshHeadViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
        headView.tableView = self as UITableView
        self.addSubview(headView)
        headerView = headView
    }
    
    func addFootView(){
        footView = ZLSwiftFootView(frame: CGRectMake(0, -ZLSwithRefreshFootViewHeight, self.frame.size.width, ZLSwithRefreshHeadViewHeight))
        footView.backgroundColor = UIColor.lightGrayColor()
        
        let tempTableView :UITableView = self as UITableView
        tempTableView.tableFooterView = footView
        tempTableView.contentInset = UIEdgeInsetsMake(0, 0, -ZLSwithRefreshFootViewHeight, 0)
    }
    
    //MARK: Observer KVO Method
    func addObserver(){
        if(addObserverNum == 0){
            self.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: nil)
        }
//        else{
//            self.removeObserver()
//            self.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: nil)
//        }
        addObserverNum+=1
    }
    
    func removeObserver(){
//        self.removeObserver(self, forKeyPath: contentOffsetKeyPath)
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {

        var scrollView = self
        let tempTableView :UITableView = self as UITableView
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
            
//            println("v = \(v)")
            if ((Int)(abs(v)) > 0){
                headerView.imgName = "\((Int)(abs(v)))"
            }
        }
        
        if tempTableView.tableFooterView != nil && scrollViewContentOffsetY > 0{
            // 上啦加载更多
            var nowContentOffsetY:CGFloat = scrollView.contentOffset.y + self.frame.size.height
            var tableViewMaxHeight:CGFloat = CGRectGetMidY(tempTableView.tableFooterView!.frame)
            if (nowContentOffsetY - tableViewMaxHeight) > ZLSwithRefreshFootViewHeight * 0.3{
                if scrollView.dragging == false {
                    if loadMoreTempAction != nil {
                        
                        refreshStatus = .LoadMore
                        UIView.animateWithDuration(0.25, animations: { () -> Void in
                            scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0, 0, 0)
                        })
                        footView.title = ZLSwithRefreshLoadingText
                        if(loadMoreTempAction != nil){
                            loadMoreTempAction()
                            loadMoreTempAction = {}
                        }
                        
                    } else {
                        footView.title = ZLSwithRefreshMessageText
                    }
                }
                

            }else{
                loadMoreTempAction = loadMoreAction
                footView.title = ZLSwithRefreshFootViewText
            }
        }
    }
    
    func doneRefresh(){
        if headerView.headImageView.isAnimating() {
            headerView.stopAnimation()
        }
        if refreshStatus == .LoadMore {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0, -ZLSwithRefreshFootViewHeight, 0)
            })
        }else if refreshStatus == .Refresh {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                var vc:UIViewController = self.getViewControllerWithView(self) as UIViewController
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
    }

    func getViewControllerWithView(vcView:UIView) -> AnyObject{
        if( (vcView.nextResponder()?.self.isEqual(UIViewController.self) ) != nil){
            return vcView.nextResponder() as UIViewController
        }
        
        return self.getViewControllerWithView(vcView.superview!)
    }
    
}

