//
//  AlertManager.swift
//  ContactAppSwiftUI
//
//  Created by ozgur on 7/21/22.
//

import Foundation
import UIKit

import SwiftUI;
class AlertManager
{
   
 
  static var shared = AlertManager()

    
//    @ObservedObject var analyticsHelper = AnalyticsHelper.shared
    
    
    func showAlert(alert: UIAlertController) {
        if let controller =   UIApplication.shared.mainKeyWindow?.rootViewController
 {
            controller.present(alert, animated: true)
        }
    }
    

    func showAlertGoSettings(){
        print(#function)
        let doYouLove = UIAlertController(title: "Congratulations!", message: "AI started to draw! App is not authorized for push notifications. Please come back after 1.5 hour. If you want to allow push notifications, go to Settings->Avatar Maker", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "Later", style: .default) { _ in
          
        
          
        }
        let yesAction = UIAlertAction(title: "Go to settings ->", style: .default) { _ in
           
            let url = URL(string:UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!){
                // can open succeeded.. opening the url
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            
        }
        
        doYouLove.addAction(noAction)
        doYouLove.addAction(yesAction)
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(doYouLove, animated: true, completion: nil)
            
        }
    }
    
  func showAlert(message:String) {
      print(#function)
      let alertController = UIAlertController(title: "Info!", message: message, preferredStyle: .alert)

      let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
        alertController.dismiss(animated: true)
      }


      alertController.addAction(okAction)
      let root = UIApplication.shared.mainKeyWindow?.rootViewController

     root?.present(alertController, animated: true, completion: nil)
  }
    
    func getInfo(completion:@escaping()->()) {
        print(#function)
        let writePromptInfo = UIAlertController(title: "Info", message: "test test", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
//            self.analyticsHelper.logEvent(name: "tapped_Ok_WritePromtInfoAlert")
            let _ = UIApplication.shared.mainKeyWindow?.rootViewController
       
        }
        let moreAction = UIAlertAction(title: "More", style: .default) { _ in
//            self.analyticsHelper.logEvent(name: "tapped_More_WritePromtInfoAlert")
        completion()
 
        }
        
        writePromptInfo.addAction(okAction)
        writePromptInfo.addAction(moreAction)
        
        UIApplication.shared.windows.first?.rootViewController?.present(writePromptInfo, animated: true, completion: nil)
    }
}
