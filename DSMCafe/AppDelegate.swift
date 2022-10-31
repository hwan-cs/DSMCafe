//
//  AppDelegate.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/14.
//

import UIKit
import Firebase
import FirebaseFirestore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
}

