//
//  NotificationManager.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 4.05.2023.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate{
    
    static var shared = NotificationManager()
  
    
    
    func registerForNotification() {
          

          let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
          //        center.delegate = self
          
          center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
              print("push register result ",granted)
              if error != nil{
                print("!push error")
               
                
              }else{

                DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
                }

                  
              }
            
          })
//      DispatchQueue.main.async {
//        UIApplication.shared.registerForRemoteNotifications()
//      }
//


        
      }
    func checkPushNotification(){
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { permission in
            switch permission.authorizationStatus  {
            case .authorized:
               
                print("User granted permission for notification")
//                UserDefaults.standard.set("true", forKey: "showWaitingStatusBody")
            
  
            case .denied:
                

                print("User denied notification permission")
                UserDefaults.standard.set("true", forKey: "showWaitingStatusBody")


                AlertManager.shared.showAlertGoSettings()
            case .notDetermined:
                DispatchQueue.main.async { [self] in
                     registerForNotification()
                   

                }
               
                print("Notification permission haven't been asked yet")
            case .provisional:
                // @available(iOS 12.0, *)
                print("The application is authorized to post non-interruptive user notifications.")
            case .ephemeral:
                // @available(iOS 14.0, *)
                print("The application is temporarily authorized to post notifications. Only available to app clips.")
            @unknown default:
                print("Unknow Status")
            }
        })
        
    }
}
