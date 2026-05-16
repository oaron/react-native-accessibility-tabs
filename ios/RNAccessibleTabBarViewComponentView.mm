#import "RNAccessibleTabBarViewComponentView.h"

#import <react/renderer/components/RNAccessibilityTabsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/EventEmitters.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/Props.h>
#import <react/renderer/components/RNAccessibilityTabsSpec/RCTComponentViewHelpers.h>

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

    self.accessibilityTraits |= UIAccessibilityTraitTabBar;
    if (@available(iOS 13.0, *)) {
      self.accessibilityContainerType = UIAccessibilityContainerTypeSemanticGroup;
    }
  }
  return self;
}

// Force-disable: RCTViewComponentView's base prop handling flips
// isAccessibilityElement to YES whenever accessibilityLabel is set, which would
// collapse the child tabs into one focus stop.
- (BOOL)isAccessibilityElement
{
  return NO;
}

// VoiceOver cannot find the tab buttons through RN's nested RCTView hierarchy on
// its own — depth-first walk collects every subview marked as an accessibility
// element and exposes them as our children.
- (NSArray *)accessibilityElements
{
  NSMutableArray *elements = [NSMutableArray array];
  [self collectAccessibleChildrenFrom:self into:elements];
  return elements.count > 0 ? elements : nil;
}

- (void)collectAccessibleChildrenFrom:(UIView *)view into:(NSMutableArray *)elements
{
  for (UIView *subview in view.subviews) {
    if (subview.isAccessibilityElement) {
      [elements addObject:subview];
    } else {
      [self collectAccessibleChildrenFrom:subview into:elements];
    }
  }
}

@end

Class<RCTComponentViewProtocol> RNAccessibleTabBarViewCls(void)
{
  return RNAccessibleTabBarViewComponentView.class;
}
