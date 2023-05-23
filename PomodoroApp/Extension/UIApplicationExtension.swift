//
//  KeyWindow.swift
//  Art Generator
//
//  Created by ozgur on 9/5/22.
//

import Foundation
import UIKit

extension UIApplication {
    var mainKeyWindow: UIWindow? {
        get {

                return connectedScenes
                    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                    .first { $0.isKeyWindow }

        }
    }

  var foregroundActiveScene: UIWindowScene? {
      connectedScenes
          .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
  }
}


