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
    
    @IBAction func getTweetData()
    {
        if let s = textField?.text
        {
            let searchStrings:[String] = s.components(separatedBy: " ")

            twitterHelper.tweetData.applyFilters = (searchStrings.count > 1) ? true : false;
            twitterHelper.tweetData.filterData.updateFilter(strings: searchStrings)
        }
        
        if let session = TWTRTwitter.sharedInstance().sessionStore.session()
        {
            let currentUser:String = session.userID;
            twitterHelper.getFriendsOfCurrentUser(currentUser:currentUser);
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
        twitterHelper.uiObjectToUpdate = cloudView;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        for v in cloudView.subviews {
            let containsPoint = v.bounds.contains((sender?.location(in: v))!)
            if (containsPoint)
            {
                let cv = v as! TagView
                
                let vc:TwitterTweetViewController = self.storyboard?.instantiateViewController(withIdentifier: "idTwitterTweetViewController") as! TwitterTweetViewController
                vc.setTweetData(data: twitterHelper.tweetData, forWord: cv.text.components(separatedBy: ":")[0])
                self.present(vc as! UIViewController, animated: true, completion: nil)
            }
        }
    }
}

