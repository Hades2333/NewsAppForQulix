//
//  AppDelegate.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)

        if let window = self.window {
            let nav = UINavigationController(rootViewController: NewsViewController())
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
        return true
    }
}

