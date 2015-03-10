//
//  Example2ViewController.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-9.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit

class Example2ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var datas:Int = 3
    var collectionView:UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.view.addSubview(collectionView)
        self.collectionView = collectionView
        
        weak var weakSelf = self as Example2ViewController
        collectionView.toRefreshAction { () -> () in
            weakSelf?.delay(2.0, closure: { () -> () in})
            weakSelf?.delay(2.0, closure: { () -> () in
                println("toRefreshAction success")
                weakSelf?.datas += (Int)(arc4random_uniform(4)) + 1
                collectionView.reloadData()
                collectionView.doneRefresh()
            })
        }

        collectionView.toLoadMoreAction { () -> () in
            
        }

        collectionView.nowRefresh { () -> () in
            weakSelf?.delay(2.0, closure: { () -> () in})
            weakSelf?.delay(2.0, closure: { () -> () in
                println("nowRefresh success")
                weakSelf?.datas += (Int)(arc4random_uniform(4)) + 1
                collectionView.reloadData()
                collectionView.doneRefresh()
            })
        }
    }
    
    deinit{
        self.collectionView.removeObserver(self.collectionView, forKeyPath: contentSizeKeyPath)
        self.collectionView.removeObserver(self.collectionView, forKeyPath: contentOffsetKeyPath)
    }
    
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
        
        let imageView = UIImageView(image: UIImage(named: "\(indexPath.row % 3 + 1).jpeg"))
        collectionViewCell.contentView.addSubview(imageView)
        
        return collectionViewCell
    }
    
    
    
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
