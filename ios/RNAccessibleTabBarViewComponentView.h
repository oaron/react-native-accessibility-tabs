#import <UIKit/UIKit.h>
#import <React/RCTViewComponentView.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Fabric ComponentView for <AccessibleTabBar> on iOS.
 *
 * Configures the underlying UIView with the three things React Native's JS-side
 * accessibility API cannot express on its own:
 *
 *   1. UIAccessibilityTraitTabBar       — VoiceOver announces "Tab, X of Y" on each focusable child
 *   2. accessibilityContainerType       — .semanticGroup, so VoiceOver speaks the container's
 *                                         accessibilityLabel when focus first enters the group
 *   3. accessibilityElements override   — recursive walk that finds focusable children buried
 *                                         inside RN's deeply nested RCTView hierarchy
 *
 * The container itself is forced to never be its own accessibility element so its
 * children remain individually focusable.
 */
@interface RNAccessibleTabBarViewComponentView : RCTViewComponentView
@end

NS_ASSUME_NONNULL_END
