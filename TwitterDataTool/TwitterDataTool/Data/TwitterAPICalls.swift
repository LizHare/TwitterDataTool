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
struct TwitterAPICalls {
    
    func getFriendsOfCurrentUser(currentUser:String, completion: @escaping TWTRNetworkCompletion)
    {
        let client = TWTRAPIClient()
        let getFollowersList = "https://api.twitter.com/1.1/followers/ids.json"
        let params = ["user_id": currentUser,
                      "count": "5"] // Currently a magic number
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: getFollowersList, parameters: params, error: &clientError)
        
        print("Login getting followers");
        client.sendTwitterRequest(request,completion: completion);
    }
    
    func populateTweetsFromUser(userId:String, completion: @escaping TWTRNetworkCompletion)
    {
        let client = TWTRAPIClient()
        let getFollowersList = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["user_id": userId,
                      "exclude_replies": "true"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: getFollowersList, parameters: params, error: &clientError)
        
        print("Getting Tweets for User with ID \(userId)")
        client.sendTwitterRequest(request, completion: completion)
    }
}
