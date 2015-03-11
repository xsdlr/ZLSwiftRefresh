//
//  Example2ViewController.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-9.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

class Example2ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var datas:Int = 10
    var titleStr:String {
        set {
            self.title = newValue
        }
        
        get {
            return self.titleStr
        }
    }
    
    var collectionView:UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        weak var weakSelf = self as Example2ViewController
        // 下拉刷新
        collectionView.toRefreshAction { () -> () in
            weakSelf?.delay(2.0, closure: { () -> () in})
            weakSelf?.delay(2.0, closure: { () -> () in
                println("toRefreshAction success")
                weakSelf?.datas += (Int)(arc4random_uniform(4)) + 1
                weakSelf?.collectionView.reloadData()
                weakSelf?.collectionView.doneRefresh()
            })
        }

        // 加载更多
        collectionView.toLoadMoreAction { () -> () in
            weakSelf?.delay(1.0, closure: { () -> () in})
            weakSelf?.delay(1.0, closure: { () -> () in
                println("toLoadMoreAction success")
                weakSelf?.datas += (Int)(arc4random_uniform(4)) + 1
                weakSelf?.collectionView.reloadData()
                weakSelf?.collectionView.doneRefresh()
            })
        }

        // 立马进去就刷新
        collectionView.nowRefresh { () -> () in
            weakSelf?.delay(2.0, closure: { () -> () in})
            weakSelf?.delay(2.0, closure: { () -> () in
                println("nowRefresh success")
                weakSelf?.datas += (Int)(arc4random_uniform(4)) + 1
                weakSelf?.collectionView.reloadData()
                weakSelf?.collectionView.doneRefresh()
            })
        }
    }
    
    func setupUI(){
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSizeMake(100, 100)
        flowLayout.scrollDirection = .Vertical
        
        var collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self as UICollectionViewDataSource
        collectionView.delegate = self as UICollectionViewDelegate
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    //MARK: <UICollectionViewDataSource>
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datas
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var collectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as UICollectionViewCell
        collectionViewCell.backgroundColor = UIColor.whiteColor()
        
        if ( collectionViewCell.contentView.subviews.last?.isKindOfClass(UIImageView) == true){
            collectionViewCell.contentView.subviews.last?.removeFromSuperview()
        }
        
        let imageView = UIImageView(frame: collectionViewCell.bounds)
        imageView.image = UIImage(named: "\(indexPath.row % 3 + 1).jpeg")
        imageView.contentMode = .ScaleAspectFit
        collectionViewCell.contentView.addSubview(imageView)
        
        return collectionViewCell
    }
    
    //MARK: <UICollectionViewDelegate>
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("点击了\(indexPath.item)行")
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
