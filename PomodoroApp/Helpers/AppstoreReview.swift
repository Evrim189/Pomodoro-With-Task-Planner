//
//  AnalyticsHelper.swift
//  PomodoroApp
//
//  Created by Evrim Tuncel on 23.05.2023.
//

import Foundation


import Foundation
import StoreKit
import SwiftUI

class AppstoreReview {



//    static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReview"
    
  static func askReviewIfNecessary() {
    // Get the current bundle version for the app
    let infoDictionaryKey = kCFBundleVersionKey as String
    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
    else { fatalError("Expected to find a bundle version in the info dictionary") }
    print("currentVersion:",currentVersion)
   
    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReviewKey") ?? ""
    print("lastVersionPromptedForReview:",lastVersionPromptedForReview)

    if lastVersionPromptedForReview == "" || currentVersion != lastVersionPromptedForReview
      {
        guard let scene = UIApplication.shared.foregroundActiveScene else { return }
        AnalyticsHelper.shared.logEvent(name: "askedfor_review")
        SKStoreReviewController.requestReview(in: scene)

            UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReviewKey")
      }
//        }

    }
    

}

