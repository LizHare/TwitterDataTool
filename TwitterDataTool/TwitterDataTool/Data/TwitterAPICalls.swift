//
//  TwitterAPICalls.swift
//  TwitterDataTool
//
//  Created by Autumn Crossan on 5/2/19.
//  Copyright © 2019 Liz Hare. All rights reserved.
//

import Foundation
import TwitterKit
import CloudTagView

//Twitter API already has http requests happening asyncronously.
class TwitterAPICalls {

    var opperationsCount = 0;
    var followersArray:[String] = [];
    var tweetData:TweetData = TweetData()
    var uiObjectToUpdate:CloudTagView = CloudTagView()
    
    func getFriendsOfCurrentUser(currentUser:String)
    {
        followersArray = [];
        tweetData.tweets = [];
        self.uiObjectToUpdate.tags.removeAll();
        
        let client = TWTRAPIClient()
        let getFollowersList = "https://api.twitter.com/1.1/followers/ids.json"
        let params = ["user_id": currentUser,
                      "count": "5"] // Currently a magic number
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: getFollowersList, parameters: params, error: &clientError)
        
        print("Login getting followers");
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
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
            self.populateTweetsFromUsers(userId: self.followersArray[self.opperationsCount])
            
        }
    }
    
    func populateTweetsFromUsers(userId:String)
    {
        let client = TWTRAPIClient()
        let getFollowersList = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["user_id": userId,
                      "exclude_replies": "true"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: getFollowersList, parameters: params, error: &clientError)
        
        print("Getting Tweets for User with ID \(userId)")
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(String(describing: connectionError))")
            }
            
            if data == nil {
                print("401 error");
                if(self.opperationsCount > 0) {
                    
                    self.updateUI();
                    
                    sleep(1)
                    self.opperationsCount -= 1;
                    self.populateTweetsFromUsers(userId: self.followersArray[self.opperationsCount])
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
                
                self.updateUI();
                
                sleep(1)
                self.opperationsCount -= 1;
                self.populateTweetsFromUsers(userId: self.followersArray[self.opperationsCount])
                
            }
            else{
                self.updateUI();
            }
        }
    }
    
    func updateUI () {
        self.uiObjectToUpdate.tags.removeAll();
        
        let s = self.tweetData.words.allObjects.sorted{ return self.tweetData.words.count(for: $0) > self.tweetData.words.count(for: $1) }
        for item in s.prefix(20) {
            let tv = TagView(text: "\(item): \(self.tweetData.words.count(for: item))");
            tv.isUserInteractionEnabled = false;
            self.uiObjectToUpdate.tags.append(tv);
        }
    }
}
