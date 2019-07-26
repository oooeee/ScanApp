//
//  AppDelegate.swift
//  ScanApp
//
//  Created by 大江諒介 on 2019/06/27.
//  Copyright © 2019 oe. All rights reserved.
//

import UIKit
import Firebase
import LineSDK
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var nc:UINavigationController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/4411468910")
        
        FirebaseApp.configure()
        
        // LINEにログイン
        LoginManager.shared.setup(channelID: "1593043825", universalLinkURL: nil)
        
        var loginCheck = Int()
        var storybord = UIStoryboard()
        var viewController:UIViewController
        storybord = UIStoryboard(name: "Main", bundle: nil)
        
        if let window = window {
            window.rootViewController = storybord.instantiateInitialViewController() as UIViewController?
        }
        
        if UserDefaults.standard.object(forKey: "loginOK") != nil {
            loginCheck = UserDefaults.standard.object(forKey: "loginOK") as! Int
            if loginCheck == 1 {
                viewController = storybord.instantiateViewController(withIdentifier: "cardVC") as UIViewController
                nc = UINavigationController(rootViewController: viewController)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = nc
            } else {
                viewController = storybord.instantiateViewController(withIdentifier: "lineLogin") as UIViewController
                nc = UINavigationController(rootViewController: viewController)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window!.rootViewController = nc
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return LoginManager.shared.application(app, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

