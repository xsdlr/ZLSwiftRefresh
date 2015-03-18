//
//  Example4ViewController.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-13.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

class Example4ViewController: UIViewController {

    var scrollView:UIScrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    
        self.scrollView.toRefreshAction { () -> () in
            println("toRefreshAction")
            self.delay(1.0, closure: {})
            self.delay(1.0, closure: {
                self.scrollView.doneRefresh()
            })
        }
        
        self.scrollView.toLoadMoreAction { () -> () in
            println("toLoadMoreAction")
            self.delay(1.0, closure: {})
            self.delay(1.0, closure: {
                self.scrollView.doneRefresh()
            })
        }
        
        self.scrollView.nowRefresh { () -> () in
            println("nowRefresh")
            self.delay(1.0, closure: {})
            self.delay(1.0, closure: {
                self.scrollView.doneRefresh()
            })
        }
    }

    func setupUI(){
        var scrollView:UIScrollView = UIScrollView(frame: self.view.frame)
        scrollView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(scrollView)
        
        var colum:Int = 3
        var testViewW = self.view.frame.width / (CGFloat)(colum)
        
        for i in 0..<12 {
            var row = i / colum
            var col = i % colum
            var rect:CGRect = CGRectMake(CGFloat(col) * testViewW, CGFloat(row) * testViewW, testViewW, testViewW)
            var view = UIView(frame: rect)
            view.backgroundColor = UIColor(red: CGFloat(CGFloat(arc4random_uniform(256))/255), green: CGFloat(CGFloat(arc4random_uniform(256))/255), blue: CGFloat(CGFloat(arc4random_uniform(256))/255.0), alpha: 1)
            scrollView.addSubview(view)
        }
        
        self.scrollView = scrollView
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

}
