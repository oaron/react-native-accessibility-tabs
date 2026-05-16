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

// All accessibility behavior must be expressed via getter overrides so nothing the
// Fabric base RCTViewComponentView does in its prop pipeline (recomputing traits
// from accessibilityRole, flipping isAccessibilityElement when label is set) can
// clobber it after init.

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

// Depth-first walk over the actual mounted subview tree. Fabric mounts children
// into self.subviews (via mountChildComponentView:index:), so this picks up
// TouchableOpacity / Pressable views with their accessibility props applied.
- (NSArray *)accessibilityElements
{
  NSMutableArray *elements = [NSMutableArray array];
  [self collectAccessibleChildrenFrom:self into:elements];
  if (elements.count == 0) {
    return nil;
  }
  return elements;
}

- (void)collectAccessibleChildrenFrom:(UIView *)view into:(NSMutableArray *)elements
{
  for (UIView *subview in view.subviews) {
    if (subview.isHidden || subview.accessibilityElementsHidden) {
      continue;
    }
    if (subview == self) {
      continue;
    }
    if (subview.isAccessibilityElement || subview.accessibilityLabel.length > 0) {
      [elements addObject:subview];
    } else {
      [self collectAccessibleChildrenFrom:subview into:elements];
    }
  }
}

#pragma mark - Debug

// One-shot subview-tree dump after first layout. Useful when the accessibility
// tree disagrees with what the consumer expects (e.g. children not focusable,
// container swallowing label). Visible in Xcode console / Metro logs.
- (void)layoutSubviews
{
  [super layoutSubviews];
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    RCTLogInfo(@"[AccessibleTabBar] first layout — subview tree of %@:", NSStringFromClass(self.class));
    [self dumpTreeFrom:self depth:0];
    RCTLogInfo(@"[AccessibleTabBar] self.isAccessibilityElement = %d, traits = 0x%llx, containerType = %ld, label = '%@'",
               self.isAccessibilityElement,
               (unsigned long long)self.accessibilityTraits,
               (long)self.accessibilityContainerType,
               self.accessibilityLabel ?: @"(nil)");
  });
}

- (void)dumpTreeFrom:(UIView *)view depth:(NSInteger)depth
{
  NSString *pad = [@"" stringByPaddingToLength:(NSUInteger)depth * 2
                                   withString:@" "
                              startingAtIndex:0];
  RCTLogInfo(@"[AccessibleTabBar] %@%@ a11yElem=%d label='%@' traits=0x%llx",
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
