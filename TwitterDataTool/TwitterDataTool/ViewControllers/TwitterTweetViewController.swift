//
//  TwitterTweetView.swift
//  TwitterDataTool
//
//  Created by Autumn Crossan on 5/3/19.
//  Copyright © 2019 Liz Hare. All rights reserved.
//

import Foundation
import UIKit

class TwitterTweetViewController : UITableViewController {
    
    var tweetData:TweetData = TweetData();
    var word:String = ""
    
    var dataSource:[String] = []
    
    func setTweetData (data:TweetData, forWord:String) {
        tweetData = data
        word = forWord
    }
    
    override func viewDidLoad() {
        
        self.navigationController?.title = "Tweets with \(word)"
        dataSource = tweetData.tweets.filter{
            $0.lowercased().contains(word)
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TweetTableViewCell
        
        cell.tweetLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
}
