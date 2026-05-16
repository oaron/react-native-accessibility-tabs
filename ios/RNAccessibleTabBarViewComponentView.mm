#import "RNAccessibleTabBarViewComponentView.h"

#import <React/RCTLog.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/EventEmitters.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/Props.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@implementation RNAccessibleTabBarViewComponentView

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<RNAccessibleTabBarViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RNAccessibleTabBarViewProps>();
    _props = defaultProps;
  }
  return self;
}

#pragma mark - Accessibility (getter overrides)

- (BOOL)isAccessibilityElement
{
  return NO;
}

- (UIAccessibilityTraits)accessibilityTraits
{
  return [super accessibilityTraits] | UIAccessibilityTraitTabBar;
}

- (UIAccessibilityContainerType)accessibilityContainerType
{
  if (@available(iOS 13.0, *)) {
    return UIAccessibilityContainerTypeSemanticGroup;
  }
  return UIAccessibilityContainerTypeNone;
}

- (NSArray *)accessibilityElements
{
  NSMutableArray *elements = [NSMutableArray array];
  [self collectAccessibleChildrenFrom:self into:elements];
  return elements.count > 0 ? elements : nil;
}

- (void)collectAccessibleChildrenFrom:(UIView *)view into:(NSMutableArray *)elements
{
  for (UIView *subview in view.subviews) {
    if (subview.isHidden || subview.accessibilityElementsHidden) {
      continue;
    }
    if (subview.isAccessibilityElement || subview.accessibilityLabel.length > 0) {
      [elements addObject:subview];
    } else {
      [self collectAccessibleChildrenFrom:subview into:elements];
    }
  }
}

#pragma mark - Debug logging

// Bridgeless / Fabric routing: RCTLogWarn forwards to Metro reliably; RCTLogInfo
// gets filtered in some Expo SDK 54 configs. Use Warn so we definitely see it.
- (void)layoutSubviews
{
  [super layoutSubviews];

  static dispatch_once_t once;
  dispatch_once(&once, ^{
    NSMutableArray *walked = [NSMutableArray array];
    [self collectAccessibleChildrenFrom:self into:walked];

    RCTLogWarn(@"[AccessibleTabBar] v0.1.4 STATE class=%@ isAccessibilityElement=%d traits=0x%llx (tabBar=0x%llx) containerType=%ld label='%@' subviews=%lu walked-children=%lu",
               NSStringFromClass(self.class),
               self.isAccessibilityElement,
               (unsigned long long)self.accessibilityTraits,
               (unsigned long long)UIAccessibilityTraitTabBar,
               (long)self.accessibilityContainerType,
               self.accessibilityLabel ?: @"(nil)",
               (unsigned long)self.subviews.count,
               (unsigned long)walked.count);

    RCTLogWarn(@"[AccessibleTabBar] v0.1.4 TREE follows:");
    [self dumpTreeFrom:self depth:0];
  });
}

- (void)dumpTreeFrom:(UIView *)view depth:(NSInteger)depth
{
  NSString *pad = [@"" stringByPaddingToLength:(NSUInteger)depth * 2
                                   withString:@" "
                              startingAtIndex:0];
  RCTLogWarn(@"[AccessibleTabBar] %@%@ a11yElem=%d label='%@' traits=0x%llx",
             pad,
             NSStringFromClass(view.class),
             view.isAccessibilityElement,
             view.accessibilityLabel ?: @"",
             (unsigned long long)view.accessibilityTraits);
  if (depth > 12) {
    return;
  }
  for (UIView *child in view.subviews) {
    [self dumpTreeFrom:child depth:depth + 1];
  }
}

@end

Class<RCTComponentViewProtocol> RNAccessibleTabBarViewCls(void)
{
  return RNAccessibleTabBarViewComponentView.class;
}
