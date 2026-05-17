import UIKit
import React

/// Native UIView with UIAccessibilityTraits.tabBar that properly exposes
/// its children to VoiceOver. The key is overriding accessibilityElements
/// to recursively discover React Native's deeply nested accessible views.
///
/// Without this override, VoiceOver cannot find the tab buttons because
/// React Native wraps each component in multiple layers of RCTView.
@objc(RNAccessibleTabBarView)
public class RNAccessibleTabBarView: UIView {

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    isAccessibilityElement = false
    accessibilityTraits = .tabBar
    if #available(iOS 13.0, *) {
      accessibilityContainerType = .semanticGroup
    }
  }

  public override var accessibilityElements: [Any]? {
    get {
      var elements: [Any] = []
      collectAccessibleChildren(from: self, into: &elements)
      return elements.isEmpty ? nil : elements
    }
    set { }
  }

  private func collectAccessibleChildren(from view: UIView, into elements: inout [Any]) {
    for subview in view.subviews {
      if subview.isAccessibilityElement {
        elements.append(subview)
      } else {
        collectAccessibleChildren(from: subview, into: &elements)
      }
    }
  }
}
