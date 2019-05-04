//
//  TweetData.swift
//  TwitterDataTool
//
//  Created by Autumn Crossan on 5/2/19.
//  Copyright © 2019 Liz Hare. All rights reserved.
//

import Foundation

class TweetData {
    var tweets:[String] = [];
    var words:NSCountedSet = NSCountedSet();
    var filterData:DataFilters = DataFilters(searchStrings:[""]);
    var applyFilters = false;
    
    func collectTweets (tweetsToAdd:[String]) {
        
        if (applyFilters)
        {
            let ft = tweetsToAdd.filter{
                for searchString in filterData.searchStrings {
                    if($0.contains(searchString))
                    {
                        return true;
                    }
                }
                return false;
            };
            tweets.append(contentsOf:ft);
        }
        else {
            tweets.append(contentsOf:tweetsToAdd)
        }
        getWordDataForTweets(tweetsToParse:tweets);
    }
    
    func getWordDataForTweets(tweetsToParse:[String]) {
        words = NSCountedSet();

        let w = tweetsToParse.flatMap{
            return $0.components(separatedBy: " ").map
                {
                    return $0.replacingOccurrences( of:"[^a-zA-Z0-9]", with: "", options: .regularExpression).lowercased()
                }
            }.filter{
                for commonWord in filterData.commonFilter {
                    if($0 == commonWord)
                    {
                        return false;
                    }
                }
                return true;
        };
        
        words.addObjects(from: w)
    }
}

//Contains data for both common and specific filters
struct DataFilters {

    var searchStrings:[String] = [];
    let commonFilter:[String] = ["","rt","why","am","got","im","i","the","at","there","some","my","of","be","use","than","and","this","an","would","first","a","have","each","make","water","to","from","which","like","been","in","or","she","call","is","one","do","into","who","you","had","how","time","oil","that","by","their","has","its","it","word","if","look","now","he","but","will","two","find","was","not","up","more","long","for","what","other","down","on","all","about","go","day","are","were","out","see","did","as","we","many","number","get","with","when","then","no","come","your","them","way","made","they","can","these","could","may","I","said","so","people","part"]
    
    mutating func updateFilter (strings:[String]) {
        searchStrings = strings;
    }
}
