//
//  TwitterLoginViewController.swift
//  TwitterDataTool
//
//  Created by Autumn Crossan on 5/3/19.
//  Copyright © 2019 Liz Hare. All rights reserved.
//

import Foundation
import TwitterKit
import SafariServices


class TwitterLoginViewController : UIViewController {
    var loggedIn:Bool = false;
    
    override func viewDidLoad() {
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if let session = session {
                self.loggedIn = true;
            } else {
                let errorDescription = error?.localizedDescription ?? "unknown"
                print("error: \(errorDescription)");
            }
        })
        
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if( loggedIn )
        {
            self.performSegue(withIdentifier: "transitionToMainScreen", sender: self);
        }
    }
}
