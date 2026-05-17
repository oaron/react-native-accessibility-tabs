import Foundation
import React

@objc(RNAccessibleTabBarViewManager)
class RNAccessibleTabBarViewManager: RCTViewManager {
  override func view() -> UIView! {
    return RNAccessibleTabBarView()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return false
  }
}
