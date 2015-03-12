# ZLSwiftRefresh
![image](https://github.com/MakeZL/ZLSwiftRefresh/blob/master/screenhot3.gif)

This is Swift UITableView/CollectionView pull Refresh Lib.
-------
## Use
    // 下拉刷新(Pull to Refersh)
    self.tableView.toRefreshAction({ () -> () in
        println("toRefreshAction success")
    })

    // 上拉刷新(Pull to LoadMore)
    self.tableView.toLoadMoreAction({ () -> () in
        println("toLoadMoreAction success")
        // OK
        self.tableView.endLoadMoreData()
    })
    // 马上刷新(Now to Refresh)
    self.tableView.toLoadMoreAction({ () -> () in
        println("toLoadMoreAction success")
    })

Continue to update!

