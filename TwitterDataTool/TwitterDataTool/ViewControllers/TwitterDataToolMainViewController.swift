//
//  ViewController.swift
//  TwitterDataTool
//
//  Created by Autumn Crossan on 5/1/19.
//  Copyright © 2019 Liz Hare. All rights reserved.
//

import UIKit
import TwitterKit
import SafariServices
import CloudTagView

class TwitterDataToolMainViewController: UIViewController {
    
    @IBOutlet var cloudContainer:UIView?;
    @IBOutlet var textField:UITextView?;
    @IBOutlet var relateDataButton:UIButton?;
    let cloudView = CloudTagView()
    
    let twitterHelper:TwitterAPICalls = TwitterAPICalls()
    
    var opperationsCount = 0;
    var followersArray:[String] = [];
    var tweetData:TweetData = TweetData()
    
    var cloudsToAdd:Int = 20
    
    @IBAction func getTweetData()
    {
        if let s = textField?.text
        {
            let searchStrings:[String] = s.components(separatedBy: " ")

            tweetData.applyFilters = (searchStrings.count > 1) ? true : false;
            tweetData.filterData.updateFilter(strings: searchStrings)
        }
        
        if let session = TWTRTwitter.sharedInstance().sessionStore.session()
        {
            followersArray = [];
            tweetData.tweets = [];
            self.cloudView.tags.removeAll();
            
            let currentUser:String = session.userID;
            twitterHelper.getFriendsOfCurrentUser(currentUser:currentUser) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                    return;
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    
                    if let dictionary = json as? [String: Any] {
                        if let ar = dictionary["ids"] as? [Any] {
                            for r in ar
                            {
                                self.followersArray.append(String(describing: r))
                            }
                        }
                    }
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
                
                self.opperationsCount = self.followersArray.count - 1;
                self.populateTweets();
            };
        }
    }
    
    //Psuedo recursive
    func populateTweets (){
        self.twitterHelper.populateTweetsFromUser(userId: self.followersArray[self.opperationsCount]) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(String(describing: connectionError))")
            }
            
            if data == nil {
                print("401 error");
                if(self.opperationsCount > 0) {
                    self.opperationsCount -= 1;
                    self.addClouds(self.cloudsToAdd);
                    
                    sleep(1)
                    self.populateTweets();
                }
                return;
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                if let dict = json as? [[String:Any]] {
                    //for object in dict {
                    self.tweetData.collectTweets(tweetsToAdd:Array(dict.map {
                        $0["text"] as! String //Text is always a string in their JSON
                    }));
                }
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
            
            if(self.opperationsCount > 0)
            {
                self.opperationsCount -= 1;
                self.addClouds(self.cloudsToAdd);
                sleep(1)
                self.populateTweets();
                
            }
            else{
                self.addClouds(self.cloudsToAdd);
            }
        }
    }
    
    func addClouds (_ count:Int) {
        self.cloudView.tags.removeAll();
        
        let s = self.tweetData.words.allObjects.sorted{ return self.tweetData.words.count(for: $0) > self.tweetData.words.count(for: $1) }
        for item in s.prefix(count) {
            let tv = TagView(text: "\(item): \(self.tweetData.words.count(for: item))");
            tv.isUserInteractionEnabled = false;
            self.cloudView.tags.append(tv);
        }
    }
    
    //View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)

        if let c = cloudContainer {
            cloudView.frame = CGRect(x:0, y:20, width:c.frame.width, height:10)
            c.addSubview(cloudView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Function for handling adding user interaction to the cloud views we add.
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        for v in cloudView.subviews {
            let containsPoint = v.bounds.contains((sender?.location(in: v))!)
            if (containsPoint)
            {
                let cv = v as! TagView
                
                let vc:TwitterTweetViewController = self.storyboard?.instantiateViewController(withIdentifier: "idTwitterTweetViewController") as! TwitterTweetViewController
                vc.setTweetData(data: tweetData, forWord: cv.text.components(separatedBy: ":")[0])
                self.navigationController?.pushViewController(vc as UIViewController, animated: false);
            }
        }
    }
}

