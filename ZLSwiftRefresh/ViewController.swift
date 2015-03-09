//
//  ViewController.swift
//  ZLSwiftRefresh
//
//  Created by 张磊 on 15-3-6.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UITableViewController {

    // default datas
    var datas:[AnyObject] = [
        "TableView Refresh Example ->",
//        "CollectionView Refresh Example ->",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        if cell != nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        
        cell.textLabel.text = self.datas[indexPath.row] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            var example1Vc = Example1ViewController()
            self.navigationController?.pushViewController(example1Vc as UIViewController, animated: true)
        }else if indexPath.row == 1{
//            var example2Vc = Example1ViewController()
//            self.navigationController?.pushViewController(example1Vc as UIViewController, animated: true)
        }
    }
}

