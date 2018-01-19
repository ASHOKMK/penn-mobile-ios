//
//  NotificationProtocol.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2018/1/12.
//  Copyright © 2018年 PennLabs. All rights reserved.
//

import Foundation
import UserNotifications
import SCLAlertView

protocol NotificationRequestable {}

extension NotificationRequestable where Self: UIViewController {
    
    func requestNotification () {
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                DispatchQueue.main.async {
                    self.alertForDetermination()
                }
            }
            
            if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    self.alertForDecline()
                }
            }
        })
    }
    
    func registerPushNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in
            if granted {
                // Granted
            } else {
                // Not granted
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func alertForDecline() {
        let alertView = SCLAlertView()
        alertView.addButton("Allow") {
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Checking for setting is opened or not
                    print("Setting is opened: \(success)")
                })
            }
        }
        alertView.showSuccess("Turn On Notifications", subTitle: "Go to Settings -> PennMobile -> Notification -> Turn On Notifications")
    }
    
    func alertForDetermination() {
        let alertView = SCLAlertView()
        alertView.addButton("Turn On"){
            self.registerPushNotification()
        }
        alertView.showSuccess("Enable Notifications", subTitle: "Get notifications for laundry, and our future updates!")
    }
    
}
