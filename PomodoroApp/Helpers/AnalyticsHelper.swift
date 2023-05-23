//
//  analyticsHelper.swift
//  ContactAppSwiftUI
//
//  Created by Ali Karababa on 6.04.2022.
//

import Foundation
import Firebase
import FirebaseAnalytics
//import Mixpanel

class AnalyticsHelper:ObservableObject {
    static let shared = AnalyticsHelper()
    
    
    
    func logEvent(name: String, parameters: [String:Any]? = nil) {
    
        print("firebase event:", name, "parameters", parameters?.debugDescription ?? "")
//        #if RELEASE
        Analytics.logEvent(name, parameters: parameters)
//        #endif
    }
    func logError(value: String) {

        print("firebase log error:", value)
  //        #if RELEASE
      Analytics.logEvent("error_occurred", parameters: ["value":value])
  //        #endif
    }
    
    func recordError(error:Error) {
        Crashlytics.crashlytics().record(error: error)
    }
    
    func setCustomValue(value: Any?, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
//    func mixpanelAnalyticsTrackEvent(event: String, properties: Properties?) {
//     
//        Mixpanel.mainInstance().track(event: event, properties: properties)
//      
//    }

}
