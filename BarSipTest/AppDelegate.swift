//
//  AppDelegate.swift
//  BarSipTest
//
//  Created by Vera Kuznetsova on 05.04.2021.
//

import UIKit
import AVFoundation

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                print("разрешили камеру")
            } else {
                print("не разрешили камеру")
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
            if granted {
                print("разрешили микрофон")
            } else {
                print("не разрешили микрофон")
            }
        })
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

