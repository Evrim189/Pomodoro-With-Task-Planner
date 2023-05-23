//
//  AppDelegate.swift
//  Art Generator
//
//  Created by ozgur on 9/2/22.
//

import Foundation
import UIKit
import SwiftUI
import Firebase






class AppDelegate: NSObject, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    //    @ObservedObject var analyticsHelper = AnalyticsHelper.shared
    let persistenceController = PersistenceController.shared
    
    
    var didFinishLaunching: ((AppDelegate) -> Void)?
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        didFinishLaunching?(self)
      
        
#if DEBUG
//
//            let providerFactory = AppCheckDebugProviderFactory()
//            AppCheck.setAppCheckProviderFactory(providerFactory)
//        createTestData()


#endif
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        //       For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
    

        
        return true
    }
    



    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    
        
    
    }
    
}


extension AppDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                   
        if response.notification.request.trigger is UNTimeIntervalNotificationTrigger{
             print("Receive Local Notifications")
            
            
        }
        else if response.notification.request.trigger is UNPushNotificationTrigger{
             print("Receive Remote Notifications")
//            AnalyticsHelper.shared.logEvent(name: "Kullanici_push_acti_app_arkadaydi")
            
         
            
        }
    
        let userInfo = response.notification.request.content.userInfo
        completionHandler()
    }

    //push geldigidne app aciksa bu tetikleniyor
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       print("willPresent Notifications")

       if notification.request.trigger is UNTimeIntervalNotificationTrigger{
            print("Receive Local Notifications")

           
       }
       else {
            print("Receive Remote Notifications")
//           AnalyticsHelper.shared.logEvent(name: "Kullanici_push_acti_app_acikti")
    
    

       }
       completionHandler([.banner, .list, .sound])
    }
}

