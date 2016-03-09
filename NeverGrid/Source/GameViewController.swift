//
//  GameViewController.swift
//  gettingthere
//
//  Created by Benzi on 20/06/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import Social

class GameViewController: UIViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        
        skView.ignoresSiblingOrder = false

//        skView.showsNodeCount = true
//        skView.showsFPS = true
//        skView.showsDrawCount = true
//        if usingIpad {
//            skView.showsPhysics = true
//        }
        
        
        let splashScreen = SplashScreen()
        skView.presentScene(splashScreen, transition: SKTransition.crossFadeWithDuration(0.5))
    }
    
    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        
        on(UIApplicationWillResignActiveNotification) { [weak self] in  self!.pause() }
        on(UIApplicationDidEnterBackgroundNotification) { [weak self] in self!.pause() }
        on(UIApplicationWillEnterForegroundNotification) { [weak self] in  self!.unpause() }
        on(UIApplicationDidBecomeActiveNotification) { [weak self] in  self!.unpause() }
        
        on(Notifications.Twitter) {
            (notification:NSNotification!) in
            let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetSheet.setInitialText(notification.userInfo!["message"]! as! NSString as String)
            tweetSheet.addURL(NSURL(string: "http://folded-paper.com/nevergrid"))
            self.presentViewController(tweetSheet, animated: true, completion: nil)
        }
    }
    
    func pause() {
        
        GameMusic.sharedInstance.pause()
        
        (self.view as! SKView).paused = true
        if let scene = (self.view as! SKView).scene as? GameScene {
            scene.timer.advance(true)
        }
        else if let scene = (self.view as! SKView).scene as? MainMenuScene {
            scene.timer.advance(true)
        }

        
    }
    
    func unpause() {
        
        GameMusic.sharedInstance.play()
        
        if let scene = (self.view as! SKView).scene as? GameScene {
            scene.timer.advance(false)
        } else if let scene = (self.view as! SKView).scene as? MainMenuScene {
            scene.timer.advance(false)
        }

        (self.view as! SKView).paused = false
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}

// hooks up notification centre
// in a readable way
extension UIResponder {
    func on(name:NSString, action:()->()){
        NSNotificationCenter.defaultCenter().addObserverForName(
            name as String,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: {
                _ in
                action()
        })
    }
    
    func on(name:NSString, block: (NSNotification!) -> Void) {
        NSNotificationCenter.defaultCenter().addObserverForName(
            name as String,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: block
        )
    }
}



